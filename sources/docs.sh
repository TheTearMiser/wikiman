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

projects() {
	"${conf_find:-find}" "$path" -mindepth 1 -maxdepth 1 -type d -not -name '.*' | sort
}

# One row per project; the preview and Enter target is its README.md
row() {
	file="$1/README.md"
	[ -f "$file" ] || file="$("${conf_find:-find}" "$1" -type f -name '*.md' | sort | head -n 1)"
	[ -n "$file" ] || return 0
	printf '%s\ten\t%s\t%s\n' "$(basename "$1")" "$name" "$file"
}

list() {
	available || return 1
	projects | while read -r d; do row "$d"; done
}

search() {
	available || return 1
	{
		list | awk -F '\t' -v re="$(echo "$query" | sed 's/ /|/g')" 'tolower($1) ~ tolower(re)'
		grep -r -l -i -E "$rg_query" --include='*.md' "$path" 2>/dev/null |
			sed "s|^$path/||; s|/.*||" | sort -u | while read -r p; do row "$path/$p"; done
	} | awk '!seen[$0]++'
}

eval "$1"
