#!/usr/bin/env bash
set -e

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
ROOT=$(dirname "$0")
COMMAND=$1
SIMULATOR="xcrun simctl"

if [ -z "${COMMAND}" ]; then
    echo "error: no arguments"
    exit 1
fi
shift 1

function start {
    ${SIMULATOR} bootstatus "$1" -b
}

function stop {
    ${SIMULATOR} shutdown "$1"
}

function create {
    NAME=$1
    DEVICE=$2
    shift 2
    ${SIMULATOR} delete "${NAME}" || true
    ${SIMULATOR} create "${NAME}" "${DEVICE}"
    start "${NAME}"
    install_ca ${NAME} "$@"
    stop "${NAME}"
}

function list {
    ${SIMULATOR} list --json
}

function install {
    ${SIMULATOR} install "$1" "$2"
}

function get_app_container {
    ${SIMULATOR} get_app_container "$1" "$2" "$3"
}

function run_app {
    ${SIMULATOR} launch "$1" "$2"
}

function install_ca {
    NAME=$1
    shift 1
    
    for CERT in "$@"; do
        ${SIMULATOR} keychain "${NAME}" add-root-cert "${CERT}" || ${ROOT}/install_cert.py "${NAME}" "${CERT}"
    done
}

${COMMAND} "$@"
