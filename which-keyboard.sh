#!/usr/bin/env bash
#
# NAME
#        which-keyboard.sh - Print the keyboard ID of the next keyboard event
#
# SYNOPSIS
#        which-keyboard.sh
#
# DESCRIPTION
#        Prints the keyboard ID (as listed by `xinput`) of the next keyboard
#        event. If you release the Enter key quickly enough after running this
#        command it will wait for another key press (even Ctrl or Shift will
#        work). If you release the Enter key after the program has initialised
#        it will detect the key release event and quit without waiting for more
#        input.
#
# EXAMPLES
#        setxkbmap -device $(which-keyboard) -layout no
#               Change the current keyboard to Norwegian keyboard layout
#
#        xinput --list-props $(which-keyboard)
#               Print properties of the current keyboard
#
# BUGS
#        https://github.com/l0b0/which-keyboard/issues
#
# COPYRIGHT
#        Copyright (C) 2016 Victor Engmark
#
#        This program is free software: you can redistribute it and/or modify
#        it under the terms of the GNU Affero General Public License as
#        published by the Free Software Foundation, either version 3 of the
#        License, or (at your option) any later version.
#
#        This program is distributed in the hope that it will be useful,
#        but WITHOUT ANY WARRANTY; without even the implied warranty of
#        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#        GNU Affero General Public License for more details.
#
#        You should have received a copy of the GNU Affero General Public
#        License along with this program.  If not, see
#        <http://www.gnu.org/licenses/>.
#
################################################################################

set -o errexit -o nounset -o noclobber -o pipefail

# Remove leftover files and processes on exit
trap 'stty echo; rm --recursive -- "$working_directory"; kill -- ${pids[@]}' EXIT

# Discard standard input
read -r -s -N1000 _ <&0 &
pids+=($!)

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

includes="${script_directory}/shell-includes"
# shellcheck source=shell-includes/error.sh
. "$includes"/error.sh
# shellcheck source=shell-includes/usage.sh
. "$includes"/usage.sh
# shellcheck source=shell-includes/variables.sh
. "$includes"/variables.sh
unset includes

# Process arguments
arguments="$(getopt --options h --longoptions help --name "$0" -- "$@")" || usage "$ex_usage"
eval set -- "$arguments"
unset arguments

while true
do
    case $1 in
        -h|--help)
            usage
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid argument: $1" >&2
            usage 1
            ;;
    esac
done

working_directory="$(mktemp --directory)"
cd "$working_directory"

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

printf '%s\n' 'Press any key to continue' >&2

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
