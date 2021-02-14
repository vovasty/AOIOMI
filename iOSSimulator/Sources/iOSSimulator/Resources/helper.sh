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
    ${SIMULATOR} boot "$1"
}

function stop {
    ${SIMULATOR} shutdown "$1"
}

function create {
    ${SIMULATOR} delete "$1" || true
    ${SIMULATOR} create "$1" "$2"
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

case "${COMMAND}" in
        list)
        list
        ;;
        create)
        create "$1" "$2"
        ;;
        start)
        start "$1"
        ;;
        stop)
        stop "$1"
        ;;
        install)
        install "$1" "$2"
        ;;
        get_app_container)
        get_app_container "$1" "$2" "$3"
        ;;
        run_app)
        run_app "$1" "$2"
        ;;
        *)
        echo "error: wrong command: ${command}"
        exit 1
        ;;
esac

