#!/bin/sh

name='docs'
description='Local Markdown docs'
path="${conf_docs_path:-$HOME/docs}"
case "$path" in
	'~'*) path="$HOME${path#\~}" ;;
esac

available() {
	[ -d "$path" ]
}

describe() {
	printf "%s\t%s\n" "$name" "$description"
}

info() {
	if available; then
		state="$(echo "$conf_sources" | grep -q "$name" && echo "+")"
		count="$("${conf_find:-find}" "$path" -type f -name '*.md' | wc -l | sed 's| ||g')"
		printf '%-10s %-28s %3s %8i  %s\n' "$name" "$description" "$state" "$count" "$path"
	else
		state="$(echo "$conf_sources" | grep -q "$name" && echo "x")"
		printf '%-10s %-30s %-11s (not found)\n' "$name" "$description" "$state"
	fi
}

row() {
	rel="${1#$path/}"
	proj="${rel%%/*}"
	title="${rel#*/}"
	title="${title%.md}"
	printf '%s (%s)\t%s\t%s\t%s\n' "$title" "$proj" 'en' "$name" "$1"
}

list() {
	available || return 1
	"${conf_find:-find}" "$path" -type f -name '*.md' | while read -r f; do row "$f"; done
}

search() {
	available || return 1
	{
		list | grep -i -E "$(echo "$query" | sed 's/ /|/g')"
		grep -r -l -i -E "$rg_query" --include='*.md' "$path" 2>/dev/null | while read -r f; do row "$f"; done
	} | awk '!seen[$0]++'
}

eval "$1"
