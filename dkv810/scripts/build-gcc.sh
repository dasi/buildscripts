#!/bin/sh

#---------------------------------------------------------------------------------
# build and install binutils
#---------------------------------------------------------------------------------

mkdir -p $target/binutils
cd $target/binutils

if [ ! -f configured-binutils ]
then
	CFLAGS=$cflags LDFLAGS=$ldflags ../../binutils-$BINUTILS_VER/configure \
	--prefix=$prefix --target=$target --disable-nls --disable-debug \
	--enable-poison-system-directories \
	--disable-dependency-tracking --disable-werror \
	$CROSS_PARAMS \
	|| { echo "Error configuring binutils"; exit 1; }
	touch configured-binutils
fi

if [ ! -f built-binutils ]
then
	$MAKE || { echo "Error building binutils"; exit 1; }
	touch built-binutils
fi


if [ ! -f installed-binutils ]
then
	$MAKE install || { echo "Error installing binutils"; exit 1; }
	touch installed-binutils
fi
cd $BUILDDIR

#---------------------------------------------------------------------------------
# build and install just the c compiler
#---------------------------------------------------------------------------------
mkdir -p $target/gcc
cd $target/gcc


if [ ! -f configured-gcc ]
then
	CFLAGS="$cflags" LDFLAGS="$ldflags" CFLAGS_FOR_TARGET="-O2" LDFLAGS_FOR_TARGET="" ../../gcc-$GCC_VER/configure \
	--enable-languages=c \
	--disable-multilib \
	--disable-dependency-tracking \
	--disable-threads --disable-win32-registry --disable-debug \
	--disable-libmudflap --disable-libssp --disable-libgomp \
	--with-newlib \
	--with-headers=../../newlib-$NEWLIB_VER/newlib/libc/include \
	--target=$target \
	--prefix=$prefix \
	--with-bugurl="http://wiki.devkitpro.org/index.php/Bug_Reports" \
	--with-pkgversion="devkitV810 release 0" \
	$CROSS_PARAMS \
	|| { echo "Error configuring gcc"; exit 1; }
	touch configured-gcc
fi


if [ ! -f built-gcc ]
then
	$MAKE all-gcc || { echo "Error building gcc"; exit 1; }
	touch built-gcc
fi


if [ ! -f installed-gcc ]
then
	$MAKE install-gcc || { echo "Error installing gcc"; exit 1; }
	touch installed-gcc
fi

cd $BUILDDIR
unset LDFLAGS
unset CFLAGS

#---------------------------------------------------------------------------------
# build and install newlib
#---------------------------------------------------------------------------------
mkdir -p $target/newlib
cd $target/newlib

if [ ! -f configured-newlib ]
then
	../../newlib-$NEWLIB_VER/configure \
	--target=$target \
	--prefix=$prefix \
	--disable-dependency-tracking \
	|| { echo "Error configuring newlib"; exit 1; }
	touch configured-newlib
fi

if [ ! -f built-newlib ]
then
	$MAKE || { echo "Error building newlib"; exit 1; }
	touch built-newlib
fi

if [ ! -f installed-newlib ]
then
	$MAKE install || { echo "Error installing newlib"; exit 1; }
	touch installed-newlib
fi

#---------------------------------------------------------------------------------
# build and install the final compiler
#---------------------------------------------------------------------------------

cd $BUILDDIR

cd $target/gcc

if [ ! -f built-stage2 ]
then
	$MAKE all || { echo "Error building gcc stage2"; exit 1; }
	touch built-stage2
fi

if [ ! -f installed-stage2 ]
then
	$MAKE install || { echo "Error installing gcc stage2"; exit 1; }
	touch installed-stage2
fi

rm -fr $prefix/$target/sys-include
