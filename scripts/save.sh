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
  Tool to save projects into workspace.yaml.

Usage:
  $CURRENT_SOURCE_FILE_NAME -h
  $CURRENT_SOURCE_FILE_NAME <project_name>

Options:
  -h    Show this screen."

function save_project() {
	local project
	project="${1#./}"
	project="${1#repositories/}"

	local repo_dir
	repo_dir="$(pwd)/repositories/$project"

	if [[ -n "$(git -C "$repo_dir" rev-parse --show-cdup)" ]]; then
		info "Nothing to do for %s" "$project"
		return
	fi

	info "Saving project %s" "$project"

	# Get all remotes for this project and update them one by one
	local remotes
	remotes=$(git -C "$repo_dir" remote)

	while IFS= read -r remote; do
		local remote_url
		remote_url=$(git -C "$repo_dir" remote get-url "$remote")

		"$YQ" -i ".repositories.$project.remotes.$remote = \"$remote_url\"" workspace.yaml
		info "Save remote %s for %s: %s" "$remote" "$project" "$remote_url"
	done <<<"$remotes"

	# Check if there are any worktrees and update them one by one
	local worktree_list
	if worktree_list=$(git -C "$repo_dir" worktree list --porcelain 2>/dev/null); then
		local current_worktree=""
		local current_branch=""

		while IFS= read -r line; do
			if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
				current_worktree="${BASH_REMATCH[1]}"
				continue
			fi

			if ! [[ "$line" =~ ^branch\ refs/heads/(.+)$ ]]; then
				continue
			fi

			current_branch="${BASH_REMATCH[1]}"

			# Skip the main repository directory
			if [[ "$current_worktree" == "$repo_dir" ]]; then
				continue
			fi

			# Extract worktree name from path
			local worktree_name
			worktree_name=$(basename "$current_worktree")

			# Find the remote tracking branch
			local tracking_branch
			if tracking_branch=$(git -C "$current_worktree" rev-parse --abbrev-ref "$current_branch@{upstream}" 2>/dev/null); then
				"$YQ" -i ".repositories.$project.worktrees[\"$worktree_name\"] = \"$tracking_branch\"" workspace.yaml
				info "Save worktree %s for %s: %s" "$worktree_name" "$project" "$tracking_branch"
			fi
		done <<<"$worktree_list"
	fi
}

function main() {
	while getopts ':h' option; do
		case "$option" in
		h)
			echo "$USAGE"
			exit
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

	# Check if a project name is provided
	if [ $# -eq 0 ]; then
		log "[ERROR] No project specified. Use -h for usage information."
		exit 1
	fi

	# Setup the specified project
	local project_name="$1"
	save_project "$project_name"
}

main "$@"
