#!/bin/bash

if [[ ! -e main.sh ]]
then
    echo "Must be run in phase2/scripts directory"
    exit 1
fi

source "variables.sh"
cd ..

BASE_DIR=$PWD

echo "************************************************************"
echo "Get smaccmpilot code"
echo "************************************************************"

git clone https://github.com/GaloisInc/smaccmpilot-build.git
cd smaccmpilot-build

echo "************************************************************"
echo "Configure smaccmpilot code"
echo "************************************************************"

git checkout feature/tower9
git submodule update --init
cd tower-camkes-odroid
echo "RAMSES_PATH=$BASE_DIR/ramses-demo" > RAMSES_PATH.mk
make create-sandbox
mkdir $ODROID_APP_NAME
cd ../..

echo "************************************************************"
echo "Get camkes code"
echo "************************************************************"

mkdir camkes
cd camkes
repo init -u https://github.com/smaccm/may-drop-odroid-manifest.git -b symlink
repo sync

echo "************************************************************"
echo "Link in the smaccmpilot app"
echo "************************************************************"

ln -s $BASE_DIR/smaccmpilot-build/tower-camkes-odroid/$ODROID_APP_NAME apps/$ODROID_APP_NAME

# Modify the can defconfig to fit the current app
# TODO: This may not be needed if we already have a defconfig

make odroid_timer_defconfig
sed --in-place "s/CONFIG_APP_TIMER_ODROID=y/# CONFIG_APP_TIMER_ODROID is not set/" .config
echo "CONFIG_APP_${ODROID_APP_NAME^^}=y" >>.config

# Put our odroid app into the top-level Kconfig
# TODO: This may not be needed if the app is already in the Kconfig

sed --follow-symlinks --in-place "/\"Applications\"/a\    source \"apps\/$ODROID_APP_NAME\/Kconfig\"" Kconfig
