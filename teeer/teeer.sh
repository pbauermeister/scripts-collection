#!/bin/bash
# Script (C) 2024 by P. Bauermeister.
#
# This script executes a given shell command, intercepting stdout and
# stderr merged into a given log file.
#
# As a wrapper of the given command, it forwards its output to stdout
# resp. stderr, and exits with the command's return code.
#
# Usage: teeer.sh LOGFILE COMAND [ARG...]
#
# TODO:
# - Option to format the lines, incl. timestamp, and (to help
#   distinguish stdout from stderr) prefix, and colorization.

die() {
    echo >&2 "Error: $*"
    echo >&2 "usage: $0 LOGFILE COMAND [ARG...]"
    exit 1
}

cleanup() {
    if [ -f "$ERR_LOG" ]; then
	rm -f $ERR_LOG
    fi
}

### Parse params
ALL_LOG="$1"; shift
test ! -z "$ALL_LOG" || die "Missing LOGFILE argument."
test ! -z "$1" || die "Missing COMMAND argument."

### Set up
set -e
set -o pipefail
ERR_LOG="/tmp/teeer-$$-err.log"
trap cleanup EXIT
rm -f $ALL_LOG $ERR_LOG; touch $ERR_LOG

### Subprocess handling stderr
(
    # retrieve error messages from $ERR_LOG, and tee to $ALL_LOG...
    tail -f $ERR_LOG | tee -a $ALL_LOG
) >&2 & # ... and to stderr; all this in background
fd=$! # remember subprocess id

### Command
# run command, stream err to $ERR_LOG, and tee out to stdout and $ALL_LOG
$* 2>$ERR_LOG | tee -a $ALL_LOG

### Termination
kill $fd
