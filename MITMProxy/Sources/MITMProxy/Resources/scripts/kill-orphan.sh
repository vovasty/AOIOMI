#!/usr/bin/env bash
set -e

CMD=$1
RUNNING=$(ps xu | grep "$CMD" | grep -v grep | grep -v "$0" | cut -d " " -f 2)

if [ -z "RUNNING" ]; then
    exit 0
fi

for pid in $RUNNING; do
    echo killing $pid
    kill -9 $pid
done
