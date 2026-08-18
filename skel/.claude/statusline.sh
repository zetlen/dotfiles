#!/usr/bin/env bash
# Claude Code statusline: starship's `claude-code` profile, with the payload
# fields starship has no module for rendered here and prepended to it.
#
# starship deserializes 6 of the ~20 top-level fields Claude sends
# (src/utils/statusline.rs): cwd, model, context_window, cost, workspace,
# effort. `$effort` landed upstream in #7614 on 2026-07-26, which is after
# v1.26.0 and so in no release yet; vim mode, rate limits, pr, worktree, agent
# and session_id are unmodelled entirely. Anything from that set has to come
# from here.
#
# Rendered here rather than exported to starship env_var modules because both of
# these colour by value, and a starship format string can only branch on whether
# a variable is empty, never on what it holds -- in config that would mean one
# near-identical module per vim mode.
#
# Receives the statusline JSON payload on stdin, and has to pass it along
# intact -- hence buffering it rather than piping straight through.

humanize_time() {
    total_secs=$1
    days=$((total_secs / 86400))
    hours=$(((total_secs % 86400) / 3600))
    final_str=""
    [ "$days" -gt 0 ] && final_str="${days}d"
    [ "$hours" -gt 0 ] && final_str="${final_str}${hours}h"
    [ "$days" -eq 0 ] && final_str="${final_str}$(((total_secs % 3600) / 60))m"
    printf "%s" "$final_str"
}

# Linearly interpolates two "r;g;b" strings at $3/100 (integer 0-100).
lerp_rgb() {
    local -a from=(${1//;/ }) to=(${2//;/ })
    local pct=$3 i
    local -a out=()
    for i in 0 1 2; do
        out[i]=$(( from[i] + (to[i] - from[i]) * pct / 100 ))
    done
    local IFS=';'
    echo "${out[*]}"
}

# Weekly-usage percent as an "r;g;b" string, walking green -> gold -> red the
# way [[claude_context.display]] steps through starship.toml's context-window
# gauge (same three palette colours below) -- but as one continuous ramp
# rather than three hard-edged tiers, since starship's threshold styling has
# no equivalent here and this has to pick a colour by hand. Green at 0%, gold
# at 50%, red at 100%, each half lerped separately so the midpoint lands
# exactly on gold instead of a muddy green/red blend.
usage_rgb() {
    local pct=${1%%.*}
    ((pct < 0)) && pct=0
    ((pct > 100)) && pct=100
    if ((pct <= 50)); then
        lerp_rgb "$usage_green" "$usage_gold" $((pct * 2))
    else
        lerp_rgb "$usage_gold" "$usage_red" $(((pct - 50) * 2))
    fi
}

payload="$(cat)"

# Uncomment if you ever want to examine the JSON fed to the status line directly.
# echo "$payload" >> ~/.claudestatuslinetstuff.json

# One jq call, one output line per field, read back in the same order. To add a
# field: append a jq expression below and a matching `read` above it.
{
    read -r vim_mode
    read -r effort
    read -r seven_day_used
    read -r seven_day_reset
} < <(jq -r '(.vim.mode // ""), (.effort.level // "" | ascii_upcase), (.rate_limits.seven_day.used_percentage // 0), (.rate_limits.seven_day.resets_at // "")' <<<"$payload" 2>/dev/null)



# Colours are [palettes.z] from ~/.config/starship.toml as 24-bit escapes, so
# the prefix matches the starship-rendered rest of the line instead of sitting a
# shade off it. Copies, and they drift if that palette changes, since a starship
# palette cannot be read from outside starship.
gray='115;136;136' # #738888
pink='232;85;135'  # #e85587

# Also [palettes.z] -- and also the exact colours [[claude_context.display]]
# steps through for the context-window gauge -- reused here as gradient stops
# so the weekly-usage bar reads as the same visual language.
usage_green='0;170;48'  # #00AA30
usage_gold='223;173;0'  # #dfad00
usage_red='204;36;29'   # #cc241d

# NORMAL/INSERT/VISUAL/VISUAL LINE are the complete documented set; the fallback
# shows anything Claude adds later rather than dropping it silently.
case "$vim_mode" in
    NORMAL) vim_letter=n vim_rgb='0;170;48' ;;         # green  #00AA30
    INSERT) vim_letter=i vim_rgb='215;215;43' ;;       # yellow #d7d72b
    VISUAL) vim_letter=v vim_rgb='148;0;182' ;;        # purple #9400b6
    "VISUAL LINE") vim_letter=V vim_rgb='0;178;177' ;; # cyan   #00B2B1
    "") vim_letter='' ;;
    *) vim_letter="$vim_mode" vim_rgb="$gray" ;;
esac

prefix=''
if [ -n "$vim_letter" ]; then
    printf -v prefix '\033[38;2;%sm%s\033[0m \033[38;2;%sm|\033[0m ' \
        "$vim_rgb" "$vim_letter" "$gray"
fi
suffix=''
if [ -n "$effort" ]; then
    printf -v suffix '\033[38;2;%sm%s\033[0m ' "$pink" "󰧑 ${effort:0:1}"
fi

if [ -n "$seven_day_used" ]; then
    __now="$(date +%s)"
    __resets_in="$(humanize_time $((seven_day_reset - __now)))"
    __usage_rgb="$(usage_rgb "$seven_day_used")"
    printf -v suffix '%s\033[38;2;%sm %.0f%%\033[0m  %s' \
        "$suffix" "$__usage_rgb" "$seven_day_used" "$__resets_in"
fi

# starship leads with a newline -- root `add_newline`, on by default and wanted
# in the shell prompt -- which would strand the prefix on a line of its own.
line="$(starship statusline claude-code <<<"$payload")"
printf '%s%s%s\n' "$prefix" "${line#$'\n'}" "$suffix"
