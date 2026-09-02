#!/bin/bash

__attributes_file="${HOME}/.config/git/attributes"
if [ -f "$__attributes_file" ] && grep -q 'merge=mergiraf' "$__attributes_file"; then
    sed -i.bak '/merge=mergiraf/d' "$__attributes_file"
fi
