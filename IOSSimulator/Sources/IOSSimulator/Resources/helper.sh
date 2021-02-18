#!/usr/bin/env bash
set -e

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
    ${SIMULATOR} delete "$1" || true
    ${SIMULATOR} create "$1" "$2"
    start "$1"
    if [ "$3" != "none" ]; then
        install_ca "$1" "$3"
    fi
    stop "$1"
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
    ${ROOT}/install_cert.py "$1" "$2"
}

${COMMAND} "$@"
