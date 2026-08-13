#!/usr/bin/env bash
# Unit tests for merge_json_fragments, the helper that keeps
# ~/.claude/settings.json in sync with lib/claude/settings/*.json.
#
# The merge semantics are subtle and a regression is silent and destructive:
# get object-vs-array wrong and an install run quietly wipes whichever of the
# host's own settings Claude Code wrote last. Hence these tests.

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="$(mktemp -d)" || exit 1
trap 'rm -rf "$work"' EXIT

DOTFILE_PATH="$repo"
export DOTFILE_PATH
# shellcheck source=../lib/common.sh
. "$repo/lib/common.sh"
# shellcheck source=../lib/installing.sh
. "$repo/lib/installing.sh"

fail=0
n=0

# check <name> <live_json> <jq_filter> <expected> [fragment_json...]
check() {
    local name="$1" live_json="$2" filter="$3" expected="$4"
    shift 4
    local live frags=() got i=0
    n=$((n + 1))
    live="$work/live.$n.json"
    printf '%s' "$live_json" >"$live"
    for frag_json in "$@"; do
        i=$((i + 1))
        printf '%s' "$frag_json" >"$work/frag.$n.$i.json"
        frags+=("$work/frag.$n.$i.json")
    done
    if ! merge_json_fragments "$live" "${frags[@]}" >/dev/null 2>&1; then
        printf 'FAIL %s (merge returned nonzero)\n' "$name"
        fail=1
        return
    fi
    got="$(jq -c "$filter" "$live")"
    if [ "$got" = "$expected" ]; then
        printf 'ok   %s\n' "$name"
    else
        printf 'FAIL %s\n       want: %s\n       got:  %s\n' "$name" "$expected" "$got"
        fail=1
    fi
}

# A key no fragment declares must survive untouched. This is the whole reason
# settings.json is merged rather than overwritten: `model` drifts, and `hooks`
# holds absolute paths written by plugins that do not exist on every host.
check "unmanaged scalar survives" \
    '{"model":"claude-sonnet-5","theme":"dark"}' \
    '{model,theme}' '{"model":"claude-sonnet-5","theme":"dark"}' \
    '{"attribution":{"commit":""}}'

check "unmanaged nested hook path survives" \
    '{"hooks":{"SessionStart":[{"hooks":[{"command":"/opt/abs/path.sh"}]}]}}' \
    '.hooks.SessionStart[0].hooks[0].command' '"/opt/abs/path.sh"' \
    '{"statusLine":{"type":"command"}}'

# enabledPlugins is an OBJECT, so a fragment pinning a few plugins must leave
# this host's other choices alone. If this ever becomes an array-replace, every
# per-host plugin toggle is lost on the next install run.
check "enabledPlugins merges per-key, does not replace" \
    '{"enabledPlugins":{"pyright-lsp@official":true,"local-only@x":true}}' \
    '.enabledPlugins|{pyright:."pyright-lsp@official",localonly:."local-only@x",pinned:."commit-commands@official"}' \
    '{"pyright":true,"localonly":true,"pinned":true}' \
    '{"enabledPlugins":{"commit-commands@official":true}}'

check "fragment overrides a plugin the host disabled" \
    '{"enabledPlugins":{"claude-code-setup@official":false}}' \
    '.enabledPlugins."claude-code-setup@official"' 'true' \
    '{"enabledPlugins":{"claude-code-setup@official":true}}'

# permissions.ask is an ARRAY, so the repo owns it outright -- but sibling keys
# under permissions, which the app grows by answering prompts, must survive.
check "declared array is replaced, sibling keys survive" \
    '{"permissions":{"allow":["Bash(ls:*)"],"defaultMode":"acceptEdits","ask":["stale"]}}' \
    '.permissions' \
    '{"allow":["Bash(ls:*)"],"defaultMode":"acceptEdits","ask":["mcp__aws-mcp"]}' \
    '{"permissions":{"ask":["mcp__aws-mcp"]}}'

# Later fragments win, so tool.*.json can refine a numbered fragment.
check "later fragment wins" \
    '{}' '.a' '3' '{"a":1}' '{"a":2}' '{"a":3}'

# An absent tool means its fragment is simply not passed in.
check "skipped tool fragment contributes nothing" \
    '{"enabledPlugins":{"core@official":true}}' \
    '.extraKnownMarketplaces // "absent"' '"absent"' \
    '{"enabledPlugins":{"core@official":true}}'

# An empty or missing live file is the fresh-host case.
check "empty live file is seeded" \
    '' '.attribution.commit' '""' '{"attribution":{"commit":""}}'

# A jq failure must leave the live file intact rather than truncating it.
n=$((n + 1))
live="$work/bad.json"
printf '{"keep":"me"}' >"$live"
printf 'this is not json' >"$work/bad-frag.json"
if merge_json_fragments "$live" "$work/bad-frag.json" >/dev/null 2>&1; then
    printf 'FAIL malformed fragment should fail loudly\n'
    fail=1
elif [ "$(jq -c '.keep' "$live" 2>/dev/null)" = '"me"' ]; then
    printf 'ok   malformed fragment leaves live file intact\n'
else
    printf 'FAIL malformed fragment corrupted the live file\n'
    fail=1
fi

# The real fragments in this repo must be valid JSON objects, or the installer
# fails on a host where nobody noticed a stray comma.
for frag in "$repo"/lib/claude/settings/*.json; do
    if [ "$(jq -r 'type' "$frag" 2>/dev/null)" = "object" ]; then
        printf 'ok   %s is a valid JSON object\n' "$(basename "$frag")"
    else
        printf 'FAIL %s is not valid JSON\n' "$(basename "$frag")"
        fail=1
    fi
done

# Every tool.<command>.json must name a command, since the installer derives
# the PATH lookup from the filename.
for frag in "$repo"/lib/claude/settings/tool.*.json; do
    [ -e "$frag" ] || continue
    tool="$(basename "$frag")"
    tool="${tool#tool.}"
    tool="${tool%.json}"
    if [ -n "$tool" ] && [ "$tool" = "${tool%%.*}" ]; then
        printf 'ok   %s gates on command %s\n' "$(basename "$frag")" "$tool"
    else
        printf 'FAIL %s has an unusable command name (%s)\n' "$(basename "$frag")" "$tool"
        fail=1
    fi
done

exit "$fail"
