#!/bin/bash

# Idempotent: drop any entries from a previous run, then append the current
# language list. Blank lines are stripped so the file doesn't grow per run.
__attributes_file="${HOME}/.config/git/attributes"
mkdir -p "$(dirname "$__attributes_file")"
[ -f "$__attributes_file" ] && sed -i.bak '/merge=mergiraf/d' "$__attributes_file"
mergiraf languages --gitattributes | sed '/^$/d' >> "$__attributes_file"
