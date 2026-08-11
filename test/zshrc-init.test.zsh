#!/usr/bin/env zsh
# Regression test for cached_shell_init (commit 82a5d69): tool init scripts it
# sources must be able to change global shell state. starship's init script
# runs `setopt promptsubst`; if function-local option scoping swallows it, the
# prompt renders as the literal text "$(starship prompt ...)".
#
# Each check launches a fresh interactive zsh so the full .zshrc runs. Agent
# marker variables are stripped because .zshrc.localbefore sets SIMPLE_PROMPT=1
# (no starship) when any of them are present.

fail=0
check() {
    local name=$1 expr=$2
    if env -u CLAUDECODE -u ANTIGRAVITY_AGENT -u GEMINI_CLI SIMPLE_PROMPT= \
        zsh -ic "$expr" </dev/null >/dev/null 2>&1; then
        print "ok   $name"
    else
        print "FAIL $name"
        fail=1
    fi
}

check "promptsubst survives shell startup" '[[ -o promptsubst ]]'
check "starship owns PROMPT"               '[[ $PROMPT == *starship* ]]'
# .zshrc's last command sets $? for the first prompt; optional-tool skips
# (e.g. cached_shell_init when wt is absent) must not leave it nonzero
check "startup leaves \$? clean"           'true_status=$?; [[ $true_status == 0 ]]'

exit $fail
