################################################################################
##  File:  Update-AndroidSDK.ps1
##  Desc:  Install and update Android SDK and tools
################################################################################

$cmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-7302050_latest.zip"
$cmdlineToolsArchPath = Start-DownloadWithRetry -Url $cmdlineToolsUrl -Name "cmdline-tools.zip"
$sdkInstallRoot = "C:\Program Files (x86)\Android\android-sdk"
$sdkRoot = "C:\Android\android-sdk"
Expand-Archive -Path $cmdlineToolsArchPath -DestinationPath "${sdkInstallRoot}\cmdline-tools" -Force
Rename-Item "${sdkInstallRoot}\cmdline-tools\cmdline-tools" "latest"
New-Item -Path "C:\Android" -ItemType Directory
New-Item -Path "$sdkRoot" -ItemType SymbolicLink -Value "$sdkInstallRoot"
$androidToolset = (Get-ToolsetContent).android
$sdkManager = "$sdkRoot\cmdline-tools\latest\bin\sdkmanager.bat"

for($i=0; $i -lt 100; $i++)
{
    $response += "y`r`n"
}

# Accept all the licenses
$response | & $sdkManager --licenses

Write-Output "y`n" | & $sdkManager --sdk_root=$sdkRoot "platform-tools"

# get packages info
$androidPackages = Get-AndroidPackages -AndroidSDKManagerPath $sdkManager

# platforms
[int]$platformMinVersion = $androidToolset.platform_min_version
$platformListByVersion = Get-AndroidPackagesByVersion -AndroidPackages $androidPackages `
                -PrefixPackageName "platforms;" `
                -MinimumVersion $platformMinVersion `
                -Delimiter "-" `
                -Index 1
$platformListByName = Get-AndroidPackagesByName -AndroidPackages $androidPackages `
                -PrefixPackageName "platforms;" | Where-Object {$_ -match "-\D+$"}
$platformList = $platformListByVersion + $platformListByName

# build-tools
[version]$buildToolsMinVersion = $androidToolset.build_tools_min_version
$buildToolsList = Get-AndroidPackagesByVersion -AndroidPackages $androidPackages `
                  -PrefixPackageName "build-tools;" `
                  -MinimumVersion $buildToolsMinVersion `
                  -Delimiter ";" `
                  -Index 1

Install-AndroidSDKPackages -AndroidSDKManagerPath $sdkManager `
                          -AndroidSDKRootPath $sdkRoot `
                          -AndroidPackages $platformList

Install-AndroidSDKPackages -AndroidSDKManagerPath $sdkManager `
                          -AndroidSDKRootPath $sdkRoot `
                          -AndroidPackages $buildToolsList

Install-AndroidSDKPackages -AndroidSDKManagerPath $sdkManager `
                          -AndroidSDKRootPath $sdkRoot `
                          -AndroidPackages $androidToolset.extra_list `
                          -PrefixPackageName "extras;"

Install-AndroidSDKPackages -AndroidSDKManagerPath $sdkManager `
                          -AndroidSDKRootPath $sdkRoot `
                          -AndroidPackages $androidToolset.addon_list `
                          -PrefixPackageName "add-ons;"

Install-AndroidSDKPackages -AndroidSDKManagerPath $sdkManager `
                          -AndroidSDKRootPath $sdkRoot `
                          -AndroidPackages $androidToolset.additional_tools

# NDKs
$ndkLTSMajorVersion = $androidToolset.ndk.lts
$ndkLatestMajorVersion = $androidToolset.ndk.latest

$ndkLTSPackageName = Get-AndroidPackagesByName -AndroidPackages $androidPackages `
                -PrefixPackageName "ndk;$ndkLTSMajorVersion" `
                | Sort-Object -Unique `
                | Select-Object -Last 1

$ndkLatestPackageName = Get-AndroidPackagesByName -AndroidPackages $androidPackages `
                -PrefixPackageName "ndk;$ndkLatestMajorVersion" `
                | Sort-Object -Unique `
                | Select-Object -Last 1

$androidNDKs = @($ndkLTSPackageName, $ndkLatestPackageName)


Install-AndroidSDKPackages -AndroidSDKManagerPath $sdkManager `
                          -AndroidSDKRootPath $sdkRoot `
                          -AndroidPackages $androidNDKs

$ndkLTSVersion = $ndkLTSPackageName.Split(';')[1]
$ndkLatestVersion = $ndkLatestPackageName.Split(';')[1]

# Android NDK root path.
$ndkRoot = "$sdkRoot\ndk-bundle"
# This changes were added due to incompatibility with android ndk-bundle (ndk;22.0.7026061).
# Link issue virtual-environments: https://github.com/actions/virtual-environments/issues/2481
# Link issue xamarin-android: https://github.com/xamarin/xamarin-android/issues/5526
New-Item -Path $ndkRoot -ItemType SymbolicLink -Value "$sdkRoot\ndk\$ndkLTSVersion"

if (Test-Path $ndkRoot) {
    setx ANDROID_HOME $sdkRoot /M
    setx ANDROID_SDK_ROOT $sdkRoot /M
    setx ANDROID_NDK_HOME $ndkRoot /M
    setx ANDROID_NDK_PATH $ndkRoot /M
    setx ANDROID_NDK_ROOT $ndkRoot /M
    (Get-Content -Encoding UTF8 "${ndkRoot}\ndk-build.cmd").replace('%~dp0\build\ndk-build.cmd','"%~dp0\build\ndk-build.cmd"')|Set-Content -Encoding UTF8 "${ndkRoot}\ndk-build.cmd"
} else {
    Write-Host "LTS NDK $ndkLTSVersion is not installed at path $ndkRoot"
    exit 1
}

$ndkLatestPath = "$sdkRoot\ndk\$ndkLatestVersion"
if (Test-Path $ndkLatestPath) {
    setx ANDROID_NDK_LATEST_HOME $ndkLatestPath /M
} else {
    Write-Host "Latest NDK $ndkLatestVersion is not installed at path $ndkLatestPath"
    exit 1
}

Invoke-PesterTests -TestFile "Android"
