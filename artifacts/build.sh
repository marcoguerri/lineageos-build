#!/bin/bash

set -eux

panic() {
    echo ${1}
    exit 1
}

build() {
    cd ${HOME}
    unzip -n platform-tools_r31.0.3-linux.zip -d ${HOME}/platform-tools
    export PATH="${PATH}:${HOME}/platform-tools"
    export PATH="${PATH}:${HOME}/bin"
    export USE_CCACHE=1
    export CCACHE_EXEC=/usr/bin/ccache
    export LC_ALL="C"
    export USER="<USER>"
    ccache -M 50G
    ccache -o compression=true

    # setup repositories
    cd ~/android/lineage
    yes | repo init -u https://github.com/LineageOS/android.git -b cm-13.0
    repo sync

    sudo ln -sf /usr/bin/python2 /usr/sbin/python
    sudo ln -s /usr/lib/jvm/java-8-openjdk /usr/lib/jvm/java-8-openjdk-amd64
    patch -p1 < roomservice.patch || true

    # -eu do not play week with breakfast/brunch code paths, which
    # at times might make use of unbound variables or command with
    # non-zero exit code

    set +xeu
    TOP=$(pwd) source build/envsetup.sh
    breakfast espressowifi
    patch -p1 < roomservice.xml.patch || true

    # sync repos again after the addition of vendor/samsung and vendor/ti
    repo sync

    croot
    brunch espressowifi
}

build=0
if [ -t 1 ]; then
  read -r -p "Continue with building LineageOS image? (will drop into shell otherwise) (y/n)?" choice
  case "$choice" in
    y|Y ) echo "Starting build"; build=1;;
    n|N ) echo "Skipping build"; build=0;;
    * ) echo "invalid";;
  esac
fi

if [ "${build}" -eq 1 ]; then
  build
else
  exec /bin/bash
fi
