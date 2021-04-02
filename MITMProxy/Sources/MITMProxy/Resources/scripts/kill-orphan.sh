#!/usr/bin/env bash
set -e

CMD=$1
RUNNING=$(pgrep -f "$CMD")

if [ -z "RUNNING" ]; then
    exit 0
fi

for pid in $RUNNING; do
    echo killing $pid
    kill -9 $pid
done
