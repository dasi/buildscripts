#!/bin/sh

DEVKITPPC=$TOOLPATH/devkitPPC

#---------------------------------------------------------------------------------
# Install and build the gamecube crt and libogc
#---------------------------------------------------------------------------------

echo "installing specs ..."
powerpc-gekko-gcc -dumpspecs $DEVKITPPC/lib/gcc/$target/$GCC_VER/specs
cp `pwd`/dkppc/crtls/gcn* $DEVKITPPC/$target/lib/
cp `pwd`/dkppc/crtls/specs $DEVKITPPC/lib/gcc/$target/$GCC_VER/specs
#---------------------------------------------------------------------------------
# copy base rulesets
#---------------------------------------------------------------------------------
cp `pwd`/dkppc/rules/gamecube_rules dkppc/rules/base_rules $DEVKITPPC

echo "building libogc ..."
cd $LIBOGC_SRCDIR
$MAKE
echo "installing libogc ..."
$MAKE install



