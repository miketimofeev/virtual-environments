################################################################################
##  File:  Install-Swig.ps1
##  Desc:  Install Swig.
################################################################################

Choco-Install -PackageName Swig

Invoke-PesterTests -TestFile "Tools" -TestName "swig"