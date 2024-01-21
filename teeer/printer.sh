#!/bin/sh
# Example script to demo the teeer.sh.
# Usage: ./teeer.sh all.out ./printer.sh Hello World
set -e
while true; do
    echo "err> [$(date)] $*" >&2
    echo "out> [$(date)] $*"
    sleep 1
done
