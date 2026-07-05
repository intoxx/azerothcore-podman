#!/usr/bin/env sh

set -euo pipefail
cd "$(dirname "$0")"

# Target container
TARGET_IMAGE='ac/worldserver'
# AzerothCore build directory
AC_BUILD_DIRECTORY='../core/build'
AC_SOURCE_DIRECTORY='../core/azerothcore-wotlk'

echo "Copying data directory from $AC_SOURCE_DIRECTORY to ./azerothcore-wotlk"
rm -rf azerothcore-wotlk && 
	mkdir -p azerothcore-wotlk && 
	cp -rv "$AC_SOURCE_DIRECTORY/data" azerothcore-wotlk/ && 
	mkdir -p azerothcore-wotlk/modules/mod-playerbots &&
	cp -rv "$AC_SOURCE_DIRECTORY/modules/mod-playerbots/data" azerothcore-wotlk/modules/mod-playerbots

echo "Copying configuration files from $AC_BUILD_DIRECTORY to ./config"
rm -rf config &&
	mkdir -p config/etc && 
	cp -rv "$AC_BUILD_DIRECTORY/dist/etc/worldserver.conf" config/etc/ &&
	cp -rv "$AC_BUILD_DIRECTORY/dist/etc/modules/" config/etc/

# Create the image
CNT=`buildah from localhost/ac/opensuse-runtime`

buildah config \
	--author 'Lucas Pruvost' \
	--workingdir /ac/bin \
	--port 8085 \
	--cmd 'worldserver' \
	$CNT

# Copy the worldserver build
buildah run $CNT mkdir -p /ac/{bin,etc,logs}
buildah add $CNT "$AC_BUILD_DIRECTORY/dist/bin/worldserver" /ac/bin
buildah add $CNT "$AC_BUILD_DIRECTORY/dist/etc/worldserver.conf" /ac/etc
buildah run $CNT ln -s /ac /build
buildah run $CNT ln -s /build /build/dist # because azerothcore install prefix points to /build/dist (see cmake from build directory)
buildah run $CNT ln -s /ac/bin/worldserver /usr/local/bin/

buildah commit --squash $CNT $TARGET_IMAGE

buildah rm $CNT
