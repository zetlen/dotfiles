#!/usr/bin/env bash
# Claude Code statusline: cwd | git branch+status | model | effort | context% | vim mode
# Receives the statusline JSON payload on stdin.

{
    read -r cwd
    read -r model
    read -r used
    read -r effort
    read -r vim_mode
} < <(jq -r '.workspace.current_dir, .model.display_name,
             (.context_window.used_percentage // ""), (.effort.level // ""), (.vim.mode // "")')

RESET=$'\033[0m'
GRAY=$'\033[90m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BR_YELLOW=$'\033[93m'
BR_MAGENTA=$'\033[95m'

sep=" ${GRAY}|${RESET} "

if porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null); then
    read -r branch untracked modified staged < <(awk '
        $1 == "#" { if ($2 == "branch.head") branch = $3; next }
        $1 == "?" { u++; next }
        /^[12u]/  { if (substr($2, 1, 1) != ".") s++; if (substr($2, 2, 1) != ".") m++ }
        END { gsub(/[()]/, "", branch); print branch, u + 0, m + 0, s + 0 }' <<<"$porcelain")
    git_info="${MAGENTA} $branch${RESET}"
    [ "$untracked" -ne 0 ] && git_info="$git_info ${YELLOW}$untracked${RESET}"
    [ "$modified" -ne 0 ] && git_info="$git_info ${RED}$modified${RESET}"
    [ "$staged" -ne 0 ] && git_info="$git_info ${GREEN}$staged${RESET}"
else
    git_info="${RESET}"
fi

status="${CYAN}$cwd${RESET}$git_info${sep}${BLUE}$model${RESET}"

[ -n "$effort" ] && status="$status ${BR_MAGENTA}$effort${RESET}"
[ -n "$used" ] && status="$status${sep}${BR_YELLOW}${used}${RESET}"

if [ -n "$vim_mode" ]; then
    case "$vim_mode" in
        NORMAL)        vs="n"; vc="$GREEN" ;;
        INSERT)        vs="i"; vc="$YELLOW" ;;
        VISUAL)        vs="v"; vc="$MAGENTA" ;;
        "VISUAL LINE") vs="V"; vc="$CYAN" ;;
        *)             vs="$vim_mode"; vc="$GRAY" ;;
    esac
    status="${vc} $vs$RESET$sep$status${RESET}"
fi

echo "$status"
