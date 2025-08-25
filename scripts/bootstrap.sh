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

# WARNING:
# This is not reliable when using POSIX sh
# and current script file is sourced by `source` or `.`
CURRENT_SOURCE_FILE_PATH="${BASH_SOURCE[0]:-$0}"
CURRENT_SOURCE_FILE_NAME="$(basename -- "$CURRENT_SOURCE_FILE_PATH")"
CURRENT_SOURCE_DIR_NAME="$(dirname -- "$CURRENT_SOURCE_FILE_PATH")"

source "$CURRENT_SOURCE_DIR_NAME/include.sh"

TOOLS_DIR="$(realpath "$CURRENT_SOURCE_DIR_NAME/../.tools")"
TEMP_DIR="$(realpath "$(mktemp -d)")"

function cleanup() {
    rm -rf "$TEMP_DIR"
}

# trap cleanup EXIT

function detect_platform() {
    local os
    local arch

    case "$(uname -s)" in
        Linux*)     os=linux ;;
        Darwin*)    os=darwin ;;
        *)
            error "Not supported OS: %s" "$(uname -s)"
            return 1
            ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64)   arch=amd64 ;;
        aarch64|arm64)  arch=arm64 ;;
        *)
            error "Not supported architecture: %s" "$(uname -m)"
            return 1
            ;;
    esac

    echo "${os}_${arch}"
}

function install_yq() {
	if command -v yq >/dev/null 2>&1; then
		return
	fi

	if [[ -x "$TOOLS_DIR/yq" ]]; then
		return
	fi

	info "Installing yq..."
	mkdir -p "$TOOLS_DIR"

	local binary
	binary="yq_$(detect_platform)"

	cd "$TEMP_DIR"
	wget "https://github.com/mikefarah/yq/releases/latest/download/${binary}.tar.gz" -O - | tar xz
	mv "${binary}" "$TOOLS_DIR/yq"
	cd -

	info "done"
}

function main() {
    install_yq
}

main
