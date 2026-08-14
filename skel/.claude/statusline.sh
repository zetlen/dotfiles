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

payload="$(cat)"

# One jq call, one output line per field, read back in the same order. To add a
# field: append a jq expression below and a matching `read` above it.
{
    read -r vim_mode
    read -r effort
} < <(jq -r '(.vim.mode // ""), (.effort.level // "")' <<<"$payload" 2>/dev/null)

# Colours are [palettes.z] from ~/.config/starship.toml as 24-bit escapes, so
# the prefix matches the starship-rendered rest of the line instead of sitting a
# shade off it. Copies, and they drift if that palette changes, since a starship
# palette cannot be read from outside starship.
gray='115;136;136' # #738888
pink='232;85;135'  # #e85587

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
    printf -v suffix '\033[38;2;%sm%s\033[0m ' "$pink" "$effort"
fi

# starship leads with a newline -- root `add_newline`, on by default and wanted
# in the shell prompt -- which would strand the prefix on a line of its own.
line="$(starship statusline claude-code <<<"$payload")"
printf '%s%s%s\n' "$prefix" "${line#$'\n'}" "$suffix"
