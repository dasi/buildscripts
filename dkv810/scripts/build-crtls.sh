#!/bin/bash

export DEVKITPRO=$TOOLPATH
export DEVKITV810=$TOOLPATH/devkitV810

#---------------------------------------------------------------------------------
# copy base rulesets
#---------------------------------------------------------------------------------

cp -v $BUILDSCRIPTDIR/dkv810/rules/* $prefix

#---------------------------------------------------------------------------------
# Install and build the vue crt
#---------------------------------------------------------------------------------

cp -v $BUILDSCRIPTDIR/dkv810/crtls/* $prefix/$target/lib/
cd $prefix/$target/lib/
$MAKE CRT=vue
$MAKE CRT=pcfx
