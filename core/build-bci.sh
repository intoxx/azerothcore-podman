#!/usr/bin/env sh

set -euo pipefail
cd "$(dirname "$0")"

# Target container
TARGET_IMAGE="ac/opensuse-bci"

# 1. Create the base image with its dependencies
CNT=`buildah from registry.opensuse.org/opensuse/tumbleweed`

# 2. Add MySQL 8.4 repository (from SUSE) because MariaDB isn't compatible
buildah run $CNT rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2025
buildah run $CNT zypper -n addrepo https://repo.mysql.com/yum/mysql-8.4-community/suse/15/x86_64/ mysql-8.4-community
buildah run $CNT zypper -n refresh

# 3. Remove cache
buildah run $CNT zypper -n clean -a
buildah run $CNT sh -c 'rm -rf /var/log/{lastlog,tallylog,zypper.log,zypp/history,YaST2}'

# 4. Commit the image and clean container
buildah commit --squash $CNT $TARGET_IMAGE
buildah rm $CNT
