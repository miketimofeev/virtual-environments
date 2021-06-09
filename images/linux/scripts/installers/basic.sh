#!/bin/bash -e
################################################################################
##  File:  basic.sh
##  Desc:  Installs basic command line utilities and dev packages
################################################################################
source $HELPER_SCRIPTS/install.sh
source $HELPER_SCRIPTS/os.sh

common_packages=$(get_toolset_value .apt.common_packages[])
cmd_packages=$(get_toolset_value .apt.cmd_packages[])
for package in $common_packages $cmd_packages; do
    echo "Install $package"
    apt-get install -y --no-install-recommends $package
done

if isUbuntu16; then
    wget https://www.openssl.org/source/openssl-1.1.1k.tar.gz
    tar xzvf openssl-1.1.1k.tar.gz
    cd openssl-1.1.1k
    ./config --openssldir=/etc/ssl '-Wl,--enable-new-dtags,-rpath,$(LIBRPATH)'
    make
    make install
    ln -sf /etc/ssl/bin/openssl /usr/bin/openssl
    cd ..
    rm -rf openssl-1.1.1k*
fi

invoke_tests "Apt"