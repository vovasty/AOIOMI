#!/usr/bin/env bash
set -e

ROOT=$(dirname "$0")
COMMAND=$1

if [ -z "${COMMAND}" ]; then
    echo "error: no arguments"
    exit 1
fi
shift 1

if [ -z "${ANDROID_SDK_ROOT}" ]; then
    echo "error: ANDROID_SDK_ROOT  is not set"
    exit 1
fi

if [ -z "${JAVA_HOME}" ]; then
    echo "error: JAVA_HOME  is not set"
    exit 1
fi

if [ -z "${AOS_EMULATOR_RUNTIME_VERSION}" ]; then
    echo "error: AOS_EMULATOR_RUNTIME_VERSION  is not set"
    exit 1
fi

if [ -z "${AOS_EMULATOR_RUNTIME_TAG}" ]; then
    echo "error: AOS_EMULATOR_RUNTIME_TAG  is not set"
    exit 1
fi

if [ -z "${AOS_EMULATOR_RUNTIME_PLATFORM}" ]; then
    echo "error: AOS_EMULATOR_RUNTIME_PLATFORM  is not set"
    exit 1
fi

ANDROID_SDK_MANGER=${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager
ANDROID_PACKAGE="system-images;android-${AOS_EMULATOR_RUNTIME_VERSION};${AOS_EMULATOR_RUNTIME_TAG};${AOS_EMULATOR_RUNTIME_PLATFORM}"

debug() { printf "=== ${FUNCNAME[1]}: %s\n" "$*" >&2; }

function install {
    debug $@
    rm -rf ${ANDROID_SDK_ROOT}/*
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools
    unzip ${ROOT}/commandlinetools-*.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/tools
	echo yes | ${ANDROID_SDK_MANGER} --channel=0 emulator "platform-tools" "platforms;android-${AOS_EMULATOR_RUNTIME_VERSION}"
    echo yes | ${ANDROID_SDK_MANGER} --install ${ANDROID_PACKAGE}
}

function check {
    debug $@
    package=$(${ANDROID_SDK_MANGER} --list_installed | grep "${ANDROID_PACKAGE}")
    [ -n "${package}" ]
}

function sdkmanager {
    debug $@
    ${ANDROID_SDK_MANGER} "$@"
}

${COMMAND} "$@"
