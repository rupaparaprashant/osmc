# (c) 2014-2015 Sam Nazarko
# email@samnazarko.co.uk

#!/bin/bash

. ../common.sh

REV="7185abd780fded3ad63168243599216bf8d652cf"
pull_source "https://github.com/osmc/ply-lite/archive/${REV}.tar.gz" "$(pwd)/src"
if [ $? != 0 ]; then echo -e "Error downloading" && exit 1; fi
# Build in native environment
build_in_env "${1}" $(pwd) "splash-osmc"
build_return=$?
if [ $build_return == 99 ]
then
	echo -e "Building splash for OSMC"
	out=$(pwd)/files
	make clean
	sed '/Package/d' -i files/DEBIAN/control
        sed '/Depends/d' -i files/DEBIAN/control
	echo "Package: ${1}-splash-osmc" >> files/DEBIAN/control
	echo "Depends: fbset, libpng12-0" >> files/DEBIAN/control
	update_sources
	handle_dep "libpng12-dev"
	pushd src/ply-lite*
	$BUILD
	if [ $? != 0 ]; then echo "Error occured during build" && exit 1; fi
	make install DESTDIR=${out}
	if [ $? != 0 ]; then echo "Error occured during installation" && exit 1; fi
	popd
	fix_arch_ctl "files/DEBIAN/control"
	dpkg_build files ${1}-splash-osmc.deb
	build_return=$?
fi
teardown_env "${1}"
exit $build_return
