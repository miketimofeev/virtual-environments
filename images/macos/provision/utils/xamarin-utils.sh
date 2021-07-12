#!/bin/bash -e -o pipefail

source ~/utils/utils.sh

# Xamarin can clean their SDKs while updating to newer versions,
# so we should be able to detect it during image generation
downloadAndInstallPKG() {
  local PKG_URL=$1
  local PKG_NAME=${PKG_URL##*/}

  download_with_retries $PKG_URL

  echo "Installing $PKG_NAME..."
  sudo installer -pkg "$TMPMOUNT/$PKG_NAME" -target /
}

buildVSMacDownloadUrl() {
    echo "https://dl.xamarin.com/VsMac/VisualStudioForMac-${1}.dmg"
}

buildMonoDownloadUrl() {
  case "$1" in
    "6.12.0.125")
      echo "https://download.visualstudio.microsoft.com/download/pr/2516b6e5-6965-4f5b-af68-d1959a446e7a/443346a56436b5e2682b7c5b5b25e990/monoframework-mdk-6.12.0.125.macos10.xamarin.universal.pkg"
      ;;
  esac
}

buildXamariniIOSDownloadUrl() {
    case "$1" in
      "14.20.0.24")
        echo "https://download.visualstudio.microsoft.com/download/pr/c2326a56-5be0-43c2-b1d7-03280d546462/0b1eb0613a4d392f4014c391c417a0e5/xamarin.ios-14.20.0.24.pkg"
        ;;
      "14.16.0.5")
        echo "https://download.visualstudio.microsoft.com/download/pr/e12e515d-da12-410b-acac-dd564a090b60/d0df6c6cfb219ebc3584bccc30e25bc5/xamarin.ios-14.16.0.5.pkg"
        ;;
      "14.14.2.5")
        echo "https://download.visualstudio.microsoft.com/download/pr/03bd1f2d-5b2a-4b65-8a7b-91da84bd241c/711a9ef9243e5765ed38b2312da39724/xamarin.ios-14.14.2.5.pkg"
        ;;
      "14.10.0.4")
        echo "https://download.visualstudio.microsoft.com/download/pr/5cbc9033-e1da-4b8b-91ea-503356b2a52a/88941ab25ab54cb9f26df34d1f07f01e/xamarin.ios-14.10.0.4.pkg"
        ;;
      "14.8.0.3")
        echo "https://download.visualstudio.microsoft.com/download/pr/573004d1-39a9-4cf7-87b0-e0eea351cd00/4ab0eae8f20e3d59c08393aa77c8c123/xamarin.ios-14.8.0.3.pkg"
        ;;
      "14.6.0.15")
        echo "https://download.visualstudio.microsoft.com/download/pr/2d952143-6407-42dc-a589-f62cebff0634/645a2544f66c775fb3b66f8998499e98/xamarin.ios-14.6.0.15.pkg"
        ;;
      "14.4.1.3")
        echo "https://download.visualstudio.microsoft.com/download/pr/68caeaf6-39d4-4b9b-85e3-d20c0a123d1e/4eea211b090c0fbef23b565939aad625/xamarin.ios-14.4.1.3.pkg"
        ;;
      "14.2.0.12")
        echo "https://download.visualstudio.microsoft.com/download/pr/7b60a920-c8b1-4798-b660-ae1a7294eb6d/bbdc2a9c6705520fd0a6d04f71e5ed3e/xamarin.ios-14.2.0.12.pkg"
        ;;
      "14.0.0.0")
        echo "https://download.visualstudio.microsoft.com/download/pr/c939bb72-556b-4e8a-a9b4-0f90e9b5e336/f906a6ce183fb73f1bcd945ac32f984b/xamarin.ios-14.0.0.0.pkg"
        ;;
      "13.20.2.2")
        echo "https://download.visualstudio.microsoft.com/download/pr/b089be2f-932a-40ab-904b-b626f9e6427b/186357848bab70642927eaf17410a051/xamarin.ios-13.20.2.2.pkg"
        ;;
  esac
}

buildXamarinMacDownloadUrl() {
    case "$1" in
      "7.14.0.24")
        echo "https://download.visualstudio.microsoft.com/download/pr/c2326a56-5be0-43c2-b1d7-03280d546462/674ac9e221090768c2bc454eff9f0bad/xamarin.mac-7.14.0.24.pkg"
        ;;
      "7.10.0.5")
        echo "https://download.visualstudio.microsoft.com/download/pr/e12e515d-da12-410b-acac-dd564a090b60/7537c3cefef02568099b29c1aa7e88a9/xamarin.mac-7.10.0.5.pkg"
        ;;
      "7.8.2.5")
        echo "https://download.visualstudio.microsoft.com/download/pr/03bd1f2d-5b2a-4b65-8a7b-91da84bd241c/ed062e57143e80070fee1366105a30a6/xamarin.mac-7.8.2.5.pkg"
        ;;
      "7.4.0.10")
        echo "https://download.visualstudio.microsoft.com/download/pr/65083286-ba60-4d43-a5bc-d8243c1823ea/acb7614cda0884db9ea09812c99e679b/xamarin.mac-7.4.0.10.pkg"
        ;;
      "7.2.0.3")
        echo "https://download.visualstudio.microsoft.com/download/pr/573004d1-39a9-4cf7-87b0-e0eea351cd00/b9b9a8e129dafd7cc8dc23a6d6b09185/xamarin.mac-7.2.0.3.pkg"
        ;;
      "7.0.0.15")
        echo "https://download.visualstudio.microsoft.com/download/pr/2d952143-6407-42dc-a589-f62cebff0634/6a061cf93f0dea18b27f65d697897b9e/xamarin.mac-7.0.0.15.pkg"
        ;;
      "6.22.1.26")
        echo "https://download.visualstudio.microsoft.com/download/pr/68caeaf6-39d4-4b9b-85e3-d20c0a123d1e/3fd74515e676be1f528bd4bec104ca6c/xamarin.mac-6.22.1.26.pkg"
        ;;
      "6.20.2.2")
        echo "https://download.visualstudio.microsoft.com/download/pr/b089be2f-932a-40ab-904b-b626f9e6427b/6aad9f3ea4fbfb92ce267e0f60b34797/xamarin.mac-6.20.2.2.pkg"
        ;;
  esac
}

buildXamarinAndroidDownloadUrl() {
    case "$1" in
      "11.3.0.4")
        echo "https://download.visualstudio.microsoft.com/download/pr/ef2c7d68-5116-4149-9d96-cd5cb3b648fc/7774e19f50fd2156adaab04500e38a58/xamarin.android-11.3.0.4.pkg"
        ;;
      "11.2.2.1")
        echo "https://download.visualstudio.microsoft.com/download/pr/2516b6e5-6965-4f5b-af68-d1959a446e7a/ebb9387736cfe9052fc77f23f6bebbf8/xamarin.android-11.2.2.1.pkg"
        ;;
      "11.1.0.26")
        echo "https://download.visualstudio.microsoft.com/download/pr/573004d1-39a9-4cf7-87b0-e0eea351cd00/97344f8a365978fce27bffb3ec30cb92/xamarin.android-11.1.0.26.pkg"
        ;;
      "11.0.2.0")
        echo "https://download.visualstudio.microsoft.com/download/pr/ea697e1c-ccb6-45cb-8425-952fb876d967/a2d2c3476403c2c238a77914cd8e8f7b/xamarin.android-11.0.2.0.pkg"
        ;;
  esac
}

installMono() {
  local VERSION=$1

  echo "Installing Mono ${VERSION}..."
  local MONO_FOLDER_NAME=$(echo $VERSION | cut -d. -f 1,2,3)
  local SHORT_VERSION=$(echo $VERSION | cut -d. -f 1,2)
  local PKG_URL=$(buildMonoDownloadUrl $VERSION)
  downloadAndInstallPKG $PKG_URL

  echo "Installing nunit3-console for Mono "$VERSION
  installNunitConsole $MONO_FOLDER_NAME

  echo "Creating short symlink '${SHORT_VERSION}'"
  sudo ln -s ${MONO_VERSIONS_PATH}/${MONO_FOLDER_NAME} ${MONO_VERSIONS_PATH}/${SHORT_VERSION}

  echo "Move to backup folder"
  sudo mv -v $MONO_VERSIONS_PATH/* $TMPMOUNT_FRAMEWORKS/mono/
}

installXamarinIOS() {
  local VERSION=$1

  echo "Installing Xamarin.iOS ${VERSION}..."
  local SHORT_VERSION=$(echo $VERSION | cut -d. -f 1,2)
  local PKG_URL=$(buildXamariniIOSDownloadUrl $VERSION)
  downloadAndInstallPKG $PKG_URL

  echo "Creating short symlink '${SHORT_VERSION}'"
  sudo ln -s ${IOS_VERSIONS_PATH}/${VERSION} ${IOS_VERSIONS_PATH}/${SHORT_VERSION}

  echo "Move to backup folder"
  sudo mv -v $IOS_VERSIONS_PATH/* $TMPMOUNT_FRAMEWORKS/ios/
}

installXamarinMac() {
  local VERSION=$1

  echo "Installing Xamarin.Mac ${VERSION}..."
  local SHORT_VERSION=$(echo $VERSION | cut -d. -f 1,2)
  local PKG_URL=$(buildXamarinMacDownloadUrl $VERSION)
  downloadAndInstallPKG $PKG_URL

  echo "Creating short symlink '${SHORT_VERSION}'"
  sudo ln -s ${MAC_VERSIONS_PATH}/${VERSION} ${MAC_VERSIONS_PATH}/${SHORT_VERSION}

  echo "Move to backup folder"
  sudo mv -v $MAC_VERSIONS_PATH/* $TMPMOUNT_FRAMEWORKS/mac/
}

installXamarinAndroid() {
  local VERSION=$1

  echo "Installing Xamarin.Android ${VERSION}..."
  local SHORT_VERSION=$(echo $VERSION | cut -d. -f 1,2)
  local PKG_URL=$(buildXamarinAndroidDownloadUrl $VERSION)
  downloadAndInstallPKG $PKG_URL

  if [ "$VERSION" == "9.4.1.0" ]; then
    # Fix symlinks for broken Xamarin.Android
    fixXamarinAndroidSymlinksInLibDir $VERSION
  fi

  echo "Creating short symlink '${SHORT_VERSION}'"
  sudo ln -s ${ANDROID_VERSIONS_PATH}/${VERSION} ${ANDROID_VERSIONS_PATH}/${SHORT_VERSION}

  echo "Move to backup folder"
  sudo mv -v $ANDROID_VERSIONS_PATH/* $TMPMOUNT_FRAMEWORKS/android/
}

createBundle() {
  local SYMLINK=$1
  local MONO_SDK=$2
  local IOS_SDK=$3
  local MAC_SDK=$4
  local ANDROID_SDK=$5

  echo "Creating bundle '$SYMLINK' (Mono $MONO_SDK; iOS $IOS_SDK; Mac $MAC_SDK; Android $ANDROID_SDK"
  deleteSymlink ${SYMLINK}
  sudo ln -s ${MONO_VERSIONS_PATH}/${MONO_SDK} ${MONO_VERSIONS_PATH}/${SYMLINK}
  sudo ln -s ${IOS_VERSIONS_PATH}/${IOS_SDK} ${IOS_VERSIONS_PATH}/${SYMLINK}
  sudo ln -s ${MAC_VERSIONS_PATH}/${MAC_SDK} ${MAC_VERSIONS_PATH}/${SYMLINK}
  sudo ln -s ${ANDROID_VERSIONS_PATH}/${ANDROID_SDK} ${ANDROID_VERSIONS_PATH}/${SYMLINK}
}

createBundleLink() {
  local SOURCE=$1
  local TARGET=$2
  echo "Creating bundle symlink '$SOURCE' -> '$TARGET'"
  deleteSymlink ${TARGET}
  sudo ln -s ${MONO_VERSIONS_PATH}/$SOURCE ${MONO_VERSIONS_PATH}/$TARGET
  sudo ln -s ${IOS_VERSIONS_PATH}/$SOURCE ${IOS_VERSIONS_PATH}/$TARGET
  sudo ln -s ${MAC_VERSIONS_PATH}/$SOURCE ${MAC_VERSIONS_PATH}/$TARGET
  sudo ln -s ${ANDROID_VERSIONS_PATH}/$SOURCE ${ANDROID_VERSIONS_PATH}/$TARGET
}

# https://github.com/xamarin/xamarin-android/issues/3457
# Recreate missing symlinks in lib for new Xamarin.Android package
# Symlink path /Library/Frameworks/Xamarin.Android.framework/Libraries
# xbuild -> xamarin.android/xbuild
# xbuild-frameworks -> xamarin.android/xbuild-frameworks
fixXamarinAndroidSymlinksInLibDir() {
  local XAMARIN_ANDROID_VERSION=$1
  local XAMARIN_ANDROID_LIB_PATH="${ANDROID_VERSIONS_PATH}/${XAMARIN_ANDROID_VERSION}/lib"

  if [ -d "${XAMARIN_ANDROID_LIB_PATH}" ]; then
      pushd "${XAMARIN_ANDROID_LIB_PATH}" > /dev/null

      local XAMARIN_ANDROID_XBUILD_DIR="${XAMARIN_ANDROID_LIB_PATH}/xbuild"
      if [ ! -d "${XAMARIN_ANDROID_XBUILD_DIR}" ]; then
          echo "${XAMARIN_ANDROID_XBUILD_DIR}"
          sudo ln -sf xamarin.android/xbuild xbuild
      fi

      local XAMARIN_ANDROID_XBUILD_FRAMEWORKS_DIR="${XAMARIN_ANDROID_LIB_PATH}/xbuild-frameworks"
      if [ ! -d "${XAMARIN_ANDROID_XBUILD_FRAMEWORKS_DIR}" ]; then
          echo "${XAMARIN_ANDROID_XBUILD_FRAMEWORKS_DIR}"
          sudo ln -sf xamarin.android/xbuild-frameworks xbuild-frameworks
      fi

      popd > /dev/null
  fi
}

installNunitConsole() {
  local MONO_VERSION=$1

  cat <<EOF > ${TMPMOUNT}/${NUNIT3_CONSOLE_BIN}
#!/bin/bash -e -o pipefail
exec /Library/Frameworks/Mono.framework/Versions/${MONO_VERSION}/bin/mono --debug \$MONO_OPTIONS $NUNIT3_PATH/nunit3-console.exe "\$@"
EOF
  sudo chmod +x ${TMPMOUNT}/${NUNIT3_CONSOLE_BIN}
  sudo mv ${TMPMOUNT}/${NUNIT3_CONSOLE_BIN} ${MONO_VERSIONS_PATH}/${MONO_VERSION}/Commands/${NUNIT3_CONSOLE_BIN}
}

downloadNUnitConsole() {
    echo "Downloading NUnit 3..."
    local NUNIT3_LOCATION='https://github.com/nunit/nunit-console/releases/download/3.6.1/NUnit.Console-3.6.1.zip'
    local NUNIT_PATH="/Library/Developer/nunit"
    NUNIT3_PATH="$NUNIT_PATH/3.6.1"

    pushd $TMPMOUNT

    sudo mkdir -p $NUNIT3_PATH
    download_with_retries $NUNIT3_LOCATION "." "nunit3.zip"

    echo "Installing NUnit 3..."
    sudo unzip nunit3.zip -d $NUNIT3_PATH
    NUNIT3_CONSOLE_BIN=nunit3-console

    popd
}

installNuget() {
  local MONO_VERSION=$1
  local NUGET_VERSION=$2
  local NUGET_URL="https://dist.nuget.org/win-x86-commandline/v${NUGET_VERSION}/nuget.exe"
  echo "Installing nuget $NUGET_VERSION for Mono $MONO_VERSION"
  cd ${MONO_VERSIONS_PATH}/${MONO_VERSION}/lib/mono/nuget
  sudo mv nuget.exe nuget_old.exe

  pushd $TMPMOUNT
  download_with_retries $NUGET_URL "." "nuget.exe"
  sudo chmod a+x nuget.exe
  sudo mv nuget.exe ${MONO_VERSIONS_PATH}/${MONO_VERSION}/lib/mono/nuget
  popd
}

createUWPShim() {
  echo "Creating UWP Shim to hack UWP build failure..."
  cat <<EOF > ${TMPMOUNT}/Microsoft.Windows.UI.Xaml.CSharp.Targets
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
<Target Name = "Build"/>
<Target Name = "Rebuild"/>
</Project>
EOF

  local UWPTARGET_PATH=/Library/Frameworks/Mono.framework/External/xbuild/Microsoft/WindowsXaml

  sudo mkdir -p $UWPTARGET_PATH/v11.0/
  sudo cp ${TMPMOUNT}/Microsoft.Windows.UI.Xaml.CSharp.Targets $UWPTARGET_PATH/v11.0/
  sudo mkdir -p $UWPTARGET_PATH/v12.0/
  sudo cp ${TMPMOUNT}/Microsoft.Windows.UI.Xaml.CSharp.Targets $UWPTARGET_PATH/v12.0/
  sudo mkdir -p $UWPTARGET_PATH/v14.0/
  sudo cp ${TMPMOUNT}/Microsoft.Windows.UI.Xaml.CSharp.Targets $UWPTARGET_PATH/v14.0/
  sudo mkdir -p $UWPTARGET_PATH/v15.0/
  sudo cp ${TMPMOUNT}/Microsoft.Windows.UI.Xaml.CSharp.Targets $UWPTARGET_PATH/v15.0/
  sudo mkdir -p $UWPTARGET_PATH/v16.0/
  sudo cp ${TMPMOUNT}/Microsoft.Windows.UI.Xaml.CSharp.Targets $UWPTARGET_PATH/v16.0/
}

createBackupFolders() {
  mkdir -p $TMPMOUNT_FRAMEWORKS/mono
  mkdir -p $TMPMOUNT_FRAMEWORKS/ios
  mkdir -p $TMPMOUNT_FRAMEWORKS/mac
  mkdir -p $TMPMOUNT_FRAMEWORKS/android
}

deleteSymlink() {
  sudo rm -f ${MONO_VERSIONS_PATH}/${1}
  sudo rm -f ${IOS_VERSIONS_PATH}/${1}
  sudo rm -f ${MAC_VERSIONS_PATH}/${1}
  sudo rm -f ${ANDROID_VERSIONS_PATH}/${1}
}