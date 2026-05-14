#!/usr/bin/env sh

set -euo pipefail
cd "$(dirname "$0")"

# Target container
TARGET_IMAGE="ac/opensuse-dev"

# 1. Create the base image with its dependencies
CNT=`buildah from localhost/ac/opensuse-bci`

# 3. Install development dependencies
# The package fuse-overlayfs is installed to support future container-in-container without having to bindmount
buildah run $CNT zypper -n install --no-recommends buildah fuse-overlayfs git cmake make gcc gcc-c++ clang libopenssl-devel libbz2-devel readline-devel ncurses-devel boost-devel libboost_filesystem-devel libboost_program_options-devel libboost_iostreams-devel libboost_regex-devel mysql-community-devel

# 4. Remove cache
buildah run $CNT zypper -n clean -a
buildah run $CNT sh -c 'rm -rf /var/log/{lastlog,tallylog,zypper.log,zypp/history,YaST2}'

# 5. Commit the image and clean container
buildah commit --squash $CNT $TARGET_IMAGE
buildah rm $CNT
