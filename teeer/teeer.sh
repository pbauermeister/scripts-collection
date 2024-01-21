#!/bin/bash
# Script (C) 2024 by P. Bauermeister.
#
# This script executes a shell command, intercepting stdout and stderr
# to a single log file, and spitting stdout and stderr as the command
# alone would do. On error, exits with the same code as the command.
#
# Usage: teeer.sh LOGFILE COMAND ARG...
#
# TODO:
# - Option to format the lines, incl. timestamp, and (to help
#   distinguish stdout from stderr) prefix, and colorization.

die() {
    echo >&2 "Error: $*"
    echo >&2 "usage: $0 LOGFILE COMAND ARG..."
    exit 1
}

cleanup() {
    rm -f $ERR_LOG
}

### Parse params

ALL_LOG="$1"; shift
test ! -z "$ALL_LOG" || die "Missing LOGFILE argument."
test ! -z "$1" || die "Missing COMMAND argument."

### Set up

set -e
set -o pipefail
ERR_LOG="/tmp/$$-err.log"
trap cleanup EXIT
rm -f $ALL_LOG $ERR_LOG; touch $ERR_LOG

### Subprocess handling stderr

(
    # retrieve error messages from $ERR_LOG, and tee to $ALL_LOG...
    tail -f $ERR_LOG | tee -a $ALL_LOG
) >&2 & # ... and to stderr; all this in background
fd=$! # remember subprocess

### Command

# run command, stream err to $ERR_LOG, and tee out to stdout and $ALL_LOG
$* 2>$ERR_LOG | tee -a $ALL_LOG

### Termination
kill $fd
