#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 Chen Linxuan <me@black-desk.cn>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# NOTE:
# Use /usr/bin/env to find shell interpreter for better portability.
# Reference: https://en.wikipedia.org/wiki/Shebang_%28Unix%29#Portability

# NOTE:
# Exit immediately if any commands (even in pipeline)
# exits with a non-zero status.
set -e
set -o pipefail

readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# This functions log messages to stderr works like printf
# with a prefix of the current script name.
# Arguments:
#   $1 - The format string.
#   $@ - Arguments to the format string, just like printf.
function log() {
	# shellcheck disable=SC2059
	printf "$@" >&2 || true
}

function info() {
    local format="$1"
    shift
    # shellcheck disable=SC2059
    log "${BLUE}[INFO]${NC} $CURRENT_SOURCE_FILE_NAME: $format\n" "$@"
}

function warn() {
    local format="$1"
    shift
    # shellcheck disable=SC2059
    log "${YELLOW}[WARN]${NC} $CURRENT_SOURCE_FILE_NAME: $format\n" "$@"
}

function error() {
    local format="$1"
    shift
    # shellcheck disable=SC2059
    log "${RED}[ERROR]${NC} $CURRENT_SOURCE_FILE_NAME: $format\n" "$@"
}
