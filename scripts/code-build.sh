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
echo "Build smaccmpilot"
echo "************************************************************"

cd smaccmpilot-build/smaccmpilot-stm32f4/src/smaccm-flight
make test-odroid
cd $ODROID_APP_NAME
make
sed -i.old 's|.*void callback_|//&|' $(find . -name "smaccm_*.h")
rm $BASE_DIR/camkes/libs/libsmaccmpilot
ln -s $BASE_DIR/camkes/apps/$ODROID_APP_NAME/libsmaccmpilot $BASE_DIR/camkes/libs
cd $BASE_DIR

echo "************************************************************"
echo "Build kernel image via camkes"
echo "************************************************************"

cd camkes
make ${ODROID_APP_NAME}_defconfig
make

cd images
if [[ -e capdl-loader-experimental-image-arm-exynos5 ]]
then
    mkimage -a 0x48000000 -e 0x48000000 -C none -A arm -T kernel -O qnx -d capdl-loader-experimental-image-arm-exynos5 odroid-image
fi

if [[ ! -e odroid-image ]]
then
    echo "Failed to build odroid-image"
    exit 1
fi

echo "************************************************************"
echo "Odroid image: $PWD/odroid-image"
echo "************************************************************"
