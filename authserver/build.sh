#!/usr/bin/env sh

set -euo pipefail
cd "$(dirname "$0")"

# Target container
TARGET_IMAGE='ac/authserver'
# AzerothCore build directory
AC_BUILD_DIRECTORY='../core/build'
AC_SOURCE_DIRECTORY='../core/azerothcore-wotlk'

echo "Copying data directory from $AC_SOURCE_DIRECTORY to ./azerothcore-wotlk"
mkdir -p azerothcore-wotlk && cp -rv "$AC_SOURCE_DIRECTORY/data" azerothcore-wotlk/

# Create the image
CNT=`buildah from localhost/ac/opensuse-runtime`

buildah config \
	--author 'Lucas Pruvost' \
	--workingdir /ac/bin \
	--port 3724 \
	--cmd 'authserver' \
	$CNT

# Copy the authserver build
buildah run $CNT mkdir -p /ac/{bin,etc,logs}
buildah add $CNT "$AC_BUILD_DIRECTORY/dist/bin/authserver" /ac/bin
buildah add $CNT "$AC_BUILD_DIRECTORY/dist/etc/authserver.conf" /ac/etc
buildah run $CNT ln -s /ac /build
buildah run $CNT ln -s /build /build/dist # because azerothcore install prefix points to /build/dist (see cmake from build directory)
buildah run $CNT ln -s /ac/bin/authserver /usr/local/bin/

buildah commit --squash $CNT $TARGET_IMAGE

buildah rm $CNT
