#!/bin/bash
# reg_server, 2024-01-09

set -e

# check arguments
if [[ $# != 2 ]]; then
    >&2 echo "Invalid arguments!"
    echo "Usage: $0 eden <build dir>"
    exit 1
fi

BUILD_APP="$1"
BUILD_DIR=$(realpath "$2")
DEPLOY_LINUX_FOLDER="${BUILD_DIR}/deploy-linux"
DEPLOY_LINUX_APPDIR_FOLDER="${BUILD_DIR}/deploy-linux/AppDir"
BIN_FOLDER="${BUILD_DIR}/bin"
BIN_EXE="${BIN_FOLDER}/${BUILD_APP}"
CPU_ARCH=$(uname -m)
BIN_EXE_MIME_TYPE=$(file -b --mime-type "${BIN_EXE}")
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
if [[ "${BIN_EXE_MIME_TYPE}" != "application/x-pie-executable" && "${BIN_EXE_MIME_TYPE}" != "application/x-executable" ]]; then
    >&2 echo "Invalid or missing main executable (${BIN_EXE})!"
    exit 1
fi

mkdir -p "${DEPLOY_LINUX_FOLDER}"
rm -rf "${DEPLOY_LINUX_APPDIR_FOLDER}"

cd "${BUILD_DIR}"

# deploy/install to deploy-linux/AppDir
DESTDIR="${DEPLOY_LINUX_APPDIR_FOLDER}" ninja install

cd "${DEPLOY_LINUX_FOLDER}"
mv -v ./usr/share ./share
mv -v ./usr ./shared

wget "$LIB4BIN" -O ./lib4bin
chmod +x ./lib4bin

./lib4bin -p -v -s -k \
    ./shared/bin/* \
	/usr/lib/libSDL* \
	/usr/lib/libXss.so* \
	/usr/lib/libdecor-0.so* \
	/usr/lib/libgamemode.so* \
	/usr/lib/qt6/plugins/audio/* \
	/usr/lib/qt6/plugins/bearer/* \
	/usr/lib/qt6/plugins/imageformats/* \
	/usr/lib/qt6/plugins/iconengines/* \
	/usr/lib/qt6/plugins/platforms/* \
	/usr/lib/qt6/plugins/platformthemes/* \
	/usr/lib/qt6/plugins/platforminputcontexts/* \
	/usr/lib/qt6/plugins/styles/* \
	/usr/lib/qt6/plugins/xcbglintegrations/* \
	/usr/lib/qt6/plugins/wayland-*/* \
	/usr/lib/pulseaudio/* \
	/usr/lib/pipewire-0.3/* \
	/usr/lib/spa-0.2/*/* \
	/usr/lib/alsa-lib/*
