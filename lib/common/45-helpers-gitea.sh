teaset() {
    local repo="$(basename "$PWD")"
    local remote="${1:-got.colonpipe.org}"
    local me="$(whoami)"
    local user="${2:-$me}"
    git remote -v | grep -F "$remote" && echo "Already there!" && return 0

    # https push auth comes from `tea login helper`, registered by
    # lib/gitconfig/tool.tea.gitconfig
    tea repos create --name "$repo" &&
        git remote add origin "https://${remote}/${user}/${repo}.git" &&
        git push --all
}
