#!/usr/bin/env bash

set -o errexit -o nounset -o noclobber -o pipefail

# Remove leftover files and processes on exit
trap 'rm --recursive -- "$dir"; kill -- ${pids[@]}' EXIT
dir="$(mktemp --directory)"
cd "$dir"

# Log key presses to file
while read -r -u 9 id
do
    # Only check devices linked to an event source
    if xinput --list-props "$id" | grep --quiet --extended-regexp '^\s+Device Node.*/dev/input/event'
    then
        # shellcheck disable=SC2094
        xinput test "$id" > "$id" &
        pids+=($!)
    fi
done 9< <(xinput --list --id-only)

# Check for key presses
while true
do
    for file in *
    do
        if [[ -s "$file" ]]
        then
            echo "$file"
            exit
        fi
    done
    sleep 0.1
done
