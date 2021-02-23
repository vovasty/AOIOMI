#!/usr/bin/env bash
set -e

ROOT=$(dirname "$0")/emulator
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

debug() { printf "=== ${FUNCNAME[1]}: %s\n" "$*" >&2; }

function start {
    debug $AVD_NAME
    "$EMULATOR" -avd "$AVD_NAME" -writable-system
}

function stop {
    debug
    "$ADB" devices | grep emulator | cut -f1 | while read line; do $ADB -s $line emu kill; done
}

function delete {
    debug $AVD_NAME
    "$AVDMANAGER" --verbose delete avd --name "$AVD_NAME"
}

function wait_booted {
    debug
   "$ADB" wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done; input keyevent 82'
}

function init {
    debug
    mkdir -p "$ANDROID_EMULATOR_HOME" "$ANDROID_AVD_HOME"
    echo "no" | "$AVDMANAGER" --verbose create avd --force --name "$AVD_NAME" -d pixel_3_xl --package "$ANDROID_PACKAGE" --tag "$ANDROID_TAG" --abi "$ANDROID_PLATFORM"
    echo hw.keyboard=yes >> "$ANDROID_AVD_HOME/$AVD_NAME.avd/config.ini"
}

function shutdown {
    debug
    PID=$(get_emulator_pid)
    "$ADB" shell su root 'am start -a com.android.internal.intent.action.REQUEST_SHUTDOWN'
    while [ -n "$PID" ]; do
        sleep 1;
        PID=$(get_emulator_pid) || true
    done
}

#for api 30
function make_root_writeable {
    debug
    adb_root
    "$ADB" shell avbctl disable-verification
    reboot
    adb_root
    "$ADB" remount
}

function create {
    debug
# shutdown emulator on exit cause child process holds swiftshell forever
    trap 'emergency_exit' EXIT
    function emergency_exit {
      echo "Stop: unexpected exit."
      stop
      exit 1
    }
    restart_adb
    stop
    init
    start &
    wait_booted
#    make_root_writeable #api 30
    if [ "$ANDROID_TAG" == "default" ]; then
        install_gapps
    fi
    set_proxy "$1"
    install_ca "$2"
 #   "$ADB" shell avbctl enable-verification #api 30
    shutdown
#crear trap to avoid erroneous exit code
    trap '' EXIT
}

function get_file {
    debug $@
    adb_root
    "$ADB" pull "$1" "$2"
}

function install_gapps {
    debug
    adb_root
    "$ADB" shell "mount -o rw,remount /"
    "$ADB" push $ROOT/gapps/etc /system
    "$ADB" push $ROOT/gapps/framework /system
    "$ADB" push $ROOT/gapps/app /system
    "$ADB" push $ROOT/gapps/priv-app /system
}

function restart_adb {
    "$ADB" kill-server
    "$ADB" start-server
}

function reboot {
    debug
    "$ADB" reboot
    "$ADB" wait-for-device
    wait_booted
}

function is_created {
    debug
    _is_created=$("$AVDMANAGER" list avd -c | grep $AVD_NAME)
    [ -n $_is_created ] || exit 1
}

function set_proxy {
    debug $@
    if [ "$1" == "none" ]; then
        return
    fi

    "$ADB" shell settings put global http_proxy $1
}

function install_apk {
    debug $@
    "$ADB" install "$1"
}

function install_ca {
    debug $@
    if [ "$1" == "none" ]; then
        return
    fi

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
    debug $@
    "$ADB" shell am start -n com.coupang.mobile/android.intent.action.MAIN
}

function run_app {
    debug $@
    "$ADB" shell am start -n "$1" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER
}

function adb {
    debug $@
    "$ADB" $@
}

function adb_root {
    debug $@
    # ignore timeout
    "$ADB" root || true
    sleep 5
    "$ADB" wait-for-device
}

function adb_unroot {
    debug $@
    # ignore timeout
    "$ADB" unroot || true
}

function get_emulator_pid {
    debug $@
    PID=$(ps x | grep $ROOT/adk/emulator/qemu/darwin-x86_64/qemu-system-x86_64 | grep -v grep | sed -e 's/^[[:space:]]*//' | cut -d ' ' -f 1)
    [ -n "$PID" ] || exit 1
    echo -n $PID
}

function is_app_installed {
    debug $@
    INSTALLED=$("$ADB" shell pm list packages | grep "$1")
    [ -n "$INSTALLED" ] || exit 1
    echo $INSTALLED
}

${COMMAND} "$@"
