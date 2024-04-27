#!/bin/sh
echo -ne '\033c\033]0;iut_gamejam24\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/iut_gamejam24.x86_64" "$@"
