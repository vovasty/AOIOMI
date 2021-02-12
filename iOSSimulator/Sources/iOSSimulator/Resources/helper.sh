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
    ${SIMULATOR} boot $1 
}

function stop {
    ${SIMULATOR} shutdown $1 
}

function create {
    ${SIMULATOR} create "$1" "$2" 2>/dev/null
}

function list {
    ${SIMULATOR} list --json 2>/dev/null
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
        *)
        echo "error: wrong command: ${command}"
        exit 1
        ;;
esac

