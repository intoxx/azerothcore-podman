#!/usr/bin/env sh

set -euo pipefail
cd "$(dirname "$0")"

# Target container
TARGET_IMAGE="ac/opensuse-runtime"

# 1. Create the base image with its dependencies
CNT=`buildah from localhost/ac/opensuse-bci`

# 3. Install runtime dependencies
buildah run $CNT zypper -n install --no-recommends libz1 liblzma5 libopenssl3 libbz2-1 readline-devel ncurses-devel libboost_atomic1_91_0 libboost_container1_91_0 libboost_random1_91_0 libboost_filesystem1_91_0 libboost_program_options1_91_0 libboost_iostreams1_91_0 libboost_regex1_91_0 mysql-community-client

# 4. Remove cache
buildah run $CNT zypper -n clean -a
buildah run $CNT sh -c 'rm -rf /var/log/{lastlog,tallylog,zypper.log,zypp/history,YaST2}'

# 5. Commit the image and clean container
buildah commit --squash $CNT $TARGET_IMAGE
buildah rm $CNT
