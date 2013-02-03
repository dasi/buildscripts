#!/bin/bash
cd $BUILDDIR

patch -p1 -d grit-$GRIT_VER -i $patchdir/grit-$GRIT_VER.patch

for archive in $hostarchives
do
	dir=$(echo $archive | sed -e 's/\(.*\)\.tar\.bz2/\1/' )
	cd $BUILDDIR/$dir
	if [ ! -f configured ]; then
		CXXFLAGS=$cflags CFLAGS=$cflags LDFLAGS=$ldflags ./configure --prefix=$prefix --disable-dependency-tracking $CROSS_PARAMS || { echo "error configuring $archive"; exit 1; }
		touch configured
	fi
	if [ ! -f built ]; then
		$MAKE || { echo "error building $archive"; exit 1; }
		touch built
	fi
	if [ ! -f installed ]; then
		$MAKE install || { echo "error installing $archive"; exit 1; }
		touch installed
	fi
done
