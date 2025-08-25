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
cd "$CURRENT_SOURCE_DIR_NAME"/..

# shellcheck disable=SC2016
USAGE="$CURRENT_SOURCE_FILE_NAME

Description:
  Tool to setup and pull specific projects into the workspace.

Usage:
  $CURRENT_SOURCE_FILE_NAME -h
  $CURRENT_SOURCE_FILE_NAME -A
  $CURRENT_SOURCE_FILE_NAME -D
  $CURRENT_SOURCE_FILE_NAME <project_name>

Options:
  -h    Show this screen.
  -D    Create directory structure for shell completion.
  -A    Setup all available projects."

function setup_directories() {
	local repositories
	repositories=$("$YQ" '.repositories | keys | .[]' workspace.yaml)

	while IFS= read -r repo_name; do
		mkdir -p "repositories/$repo_name"
	done <<<"$repositories"
}

function setup_project() {
	local project
	project="${1#./}"
	project="${1#repositories/}"

	info "Setup project %s" "$project"

	local repo_dir
	repo_dir="$(pwd)/repositories/$project"

	local repo
	repo="$("$YQ" -e ".repositories.$project.remotes.origin" workspace.yaml)"

	mkdir -p "$repo_dir"
	if [[ -n "$(git -C "$repo_dir" rev-parse --show-cdup)" ]]; then
		git clone "$repo" -- "$repo_dir"
	fi

	local remotes
	remotes=$("$YQ" -e ".repositories.$project.remotes | keys | .[]" workspace.yaml)
	while IFS= read -r remote; do
		local remote_url
		remote_url="$("$YQ" -e ".repositories.$project.remotes.$remote" workspace.yaml)"
		if git -C "$repo_dir" remote add "$remote" "$remote_url" 2>/dev/null; then
			info "Add remote %s for %s" "$remote" "$project"
			continue
		fi

		local actual_remote_url
		actual_remote_url="$(git -C "$repo_dir" remote get-url "$remote")"
		if [[ "$actual_remote_url" == "$remote_url" ]]; then
			continue
		fi

		warn "Leave %s in %s without updating" "$remote" "$project"
		warn "Except: %s" "$remote_url"
		warn "Actual: %s" "$actual_remote_url"
	done <<<"$remotes"

	git -C "$repo_dir" fetch --all

	local worktrees
	if ! "$YQ" -e ".repositories.$project.worktrees" workspace.yaml &>/dev/null; then
		return
	fi

	worktrees=$("$YQ" -e ".repositories.$project.worktrees | keys | .[]" workspace.yaml)
	while IFS= read -r worktree; do
		local remote_branch
		remote_branch="$("$YQ" -e '.repositories.'"$project"'.worktrees."'"$worktree"'"' workspace.yaml)"
		if git -C "$repo_dir" worktree repair "$repo_dir-worktrees/$worktree" &>/dev/null; then
			continue
		fi

		info "Add worktree %s for %s" "$worktree" "$project"
		git -C "$repo_dir" worktree add --track -b "$worktree" "$repo_dir-worktrees/$worktree" "$remote_branch"
	done <<<"$worktrees"
}

# Function to setup all projects
function setup_all_projects() {
	local repositories
	repositories=$("$YQ" '.repositories | keys | .[]' workspace.yaml)

	while IFS= read -r repo_name; do
		setup_project "repositories/$repo_name"
	done <<<"$repositories"
}

function main() {
	local OPT_SETUP_DIRECTORIES=false
	local OPT_SETUP_ALL_PROJECTS=false

	while getopts ':hDA' option; do
		case "$option" in
		h)
			echo "$USAGE"
			exit
			;;
		D)
			OPT_SETUP_DIRECTORIES=true
			;;
		A)
			OPT_SETUP_ALL_PROJECTS=true
			;;
		\?)
			log "[ERROR] Unknown option: -%s" "$OPTARG"
			exit 1
			;;
		esac
	done
	shift $((OPTIND - 1))

	bash ./scripts/bootstrap.sh

	if command -v yq &>/dev/null; then
		YQ="yq"
	else
		YQ="$(pwd)/.tools/yq"
	fi

	if [ "$OPT_SETUP_DIRECTORIES" = true ]; then
		setup_directories
		exit
	fi

	if [ "$OPT_SETUP_ALL_PROJECTS" = true ]; then
		setup_all_projects
		exit
	fi

	# Check if a project name is provided
	if [ $# -eq 0 ]; then
		log "[ERROR] No project specified. Use -h for usage information."
		exit 1
	fi

	# Setup the specified project
	local project_name="$1"
	setup_project "$project_name"
}

main "$@"
