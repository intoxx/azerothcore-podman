#!/usr/bin/env sh

set -euo pipefail
cd "$(dirname "$0")"

mkdir -p build

# Build inside podman with buildah
podman run \
	--rm \
	--name ac-builder \
	-v ./azerothcore-wotlk:/azerothcore-wotlk:ro,Z \
	-v ./build:/build:Z \
	ac/opensuse-dev \
	sh -c '
set -euo pipefail

# Files copy
echo "Copying Azerothcore configuration files to /build/env"
cd /build
cp -r /azerothcore-wotlk/env/dist /build/

# Configuring for compiling
export SRC_DIR=/azerothcore-wotlk
export BUILD_DIR=/build
export INSTALL_PREFIX=$BUILD_DIR/dist

echo "Configuring for compiling"
echo -e "\t- azerothcore-wotlk source directory: $SRC_DIR"
echo -e "\t- build directory: $BUILD_DIR"
echo -e "\t- installation prefix: $INSTALL_PREFIX"
cmake "$SRC_DIR" -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DWITH_WARNINGS=1 -DTOOLS_BUILD=all -DSCRIPTS=static -DMODULES=static

# Compiling
export BUILD_CORES_MAX=`nproc --all`
export BUILD_CORES=$((BUILD_CORES_MAX - 1))
echo "Compiling with $BUILD_CORES/$BUILD_CORES_MAX cores"
make -j$BUILD_CORES

# Installing
echo "Installing AzerothCore to $INSTALL_PREFIX"
make install

# Preparing authserver and worldserver configurations
echo "Preparing authserver configuration"
cp "$INSTALL_PREFIX/etc/authserver.conf.dist" "$INSTALL_PREFIX/etc/authserver.conf"
echo "Preparing worldserver configuration"
cp "$INSTALL_PREFIX/etc/worldserver.conf.dist" "$INSTALL_PREFIX/etc/worldserver.conf"

echo "AzerothCore successfully installed at $INSTALL_PREFIX"
'
