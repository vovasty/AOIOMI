#!/usr/bin/env bash
set -e

ROOT=$(dirname "$0")
COMMAND=$1
source $ROOT/env.sh

if [ -z "${COMMAND}" ]; then
    echo "error: no arguments"
    exit 1
fi
shift 1

export JAVA_HOME=${ROOT}/jdk
export ANDROID_SDK_ROOT=${ROOT}/adk
export ANDROID_AVD_HOME=~/Library/Application\ Support/com.coupang.CoupangMobileApp/avd
export ANDROID_EMULATOR_HOME=~/Library/Application\ Support/com.coupang.CoupangMobileApp/emulator

EMULATOR=$ANDROID_SDK_ROOT/emulator/emulator
ADB=$ANDROID_SDK_ROOT/platform-tools/adb
AVDMANAGER=$ANDROID_SDK_ROOT/cmdline-tools/tools/bin/avdmanager
AVD_NAME=coupang$ANDROID_VERSION

function start {
    "$EMULATOR" -avd "$AVD_NAME" -writable-system
}

function stop {
    "$ADB" devices | grep emulator | cut -f1 | while read line; do $ADB -s $line emu kill; done
}

function delete {
    "$AVDMANAGER" --verbose delete avd --name "$AVD_NAME"
}

function wait_booted {
    while [ "`$ADB shell getprop sys.boot_completed | tr -d '\r' `" != "1" ] ; do sleep 1; done
}

function create {
    mkdir -p "$ANDROID_EMULATOR_HOME" "$ANDROID_AVD_HOME"
    echo "no" | "$AVDMANAGER" --verbose create avd --force --name "$AVD_NAME" -d pixel_3_xl --package "system-images;android-$ANDROID_VERSION;default;x86" --tag "default" --abi "x86"
    echo hw.keyboard=yes >> "$ANDROID_AVD_HOME/$AVD_NAME.avd/config.ini"
}

function install_gapps {
    adb_root
    "$ADB" shell "mount -o rw,remount /"
    "$ADB" push $ROOT/gapps/etc /system
    "$ADB" push $ROOT/gapps/framework /system
    "$ADB" push $ROOT/gapps/app /system
    "$ADB" push $ROOT/gapps/priv-app /system
}

function reboot {
    "$ADB" reboot
    wait_booted
}

function is_created {
    _is_created=$("$AVDMANAGER" list avd -c | grep $AVD_NAME)
    [ -n $_is_created ] || exit 1
}

function set_proxy {
     "$ADB" shell settings put global http_proxy $1
}

function install_apk {
     "$ADB" install "$1"
}

function install_ca {
    HASH=$(openssl x509 -inform PEM -subject_hash_old -in "$1" | head -1)
    NEWNAME=$HASH.0
    NEWNAMEANDPATH=$TMPDIR/$NEWNAME

    cp "$1" "$NEWNAMEANDPATH"
    adb_root
    "$ADB" shell "mount -o rw,remount /"
    "$ADB" push "$NEWNAMEANDPATH" /system/etc/security/cacerts
    "$ADB" shell "chmod 664 /system/etc/security/cacerts/$NEWNAME"
}

function run {
    "$ADB" shell am start -n com.coupang.mobile/android.intent.action.MAIN
}

function run_app {
    "$ADB" shell am start -n "$1" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER
}

function adb {
    "$ADB" $@
}

function adb_root {
    "$ADB" root
    "$ADB" wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done; input keyevent 82'
}

function adb_unroot {
    "$ADB" unroot
    "$ADB" wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done; input keyevent 82'
}

function get_emulator_pid {
    PID=$(ps x | grep $ROOT/adk/emulator/qemu/darwin-x86_64/qemu-system-x86_64 | grep -v grep | cut -d " " -f 1)
    [ -n "$PID" ] || exit 1
    echo $PID
}

function is_app_installed {
    INSTALLED=$("$ADB" shell pm list packages | grep "$1")
    [ -n "$INSTALLED" ] || exit 1
    echo $INSTALLED
}

case "${COMMAND}" in
        start)
        start
        ;;
        stop)
        stop
        ;;
        set_proxy)
        set_proxy "$1"
        ;;
        install_ca)
        install_ca "$1"
        ;;
        create)
        create
        ;;
        delete)
        delete
        ;;
        wait_booted)
        wait_booted
        ;;
        is_created)
        is_created
        ;;
        run)
        run
        ;;
        install_gapps)
        install_gapps
        ;;
        install_apk)
        install_apk "$1"
        ;;
        reboot)
        reboot
        ;;
        run_app)
        run_app "$1"
        ;;
        adb_root)
        adb_root
        ;;
        adb_unroot)
        adb_unroot
        ;;
        adb)
        adb $@
        ;;
        get_emulator_pid)
        get_emulator_pid
        ;;
        is_app_installed)
        is_app_installed "$1"
        ;;
        *)
        echo "error: wrong command: ${command}"
        exit 1
        ;;
esac

