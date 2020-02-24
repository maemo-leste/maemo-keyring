#!/bin/sh
set -e

usage() {
	echo "usage: gpg --export DEADBEEF | $(basename "$0") ./keyrings/maemo-leste-archive.gpg"
	exit 1
}

[ -n "$1" ] || usage

cat | gpg --no-default-keyring --keyring="$1" --no-auto-check-trustdb --import -
