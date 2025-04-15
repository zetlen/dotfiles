teaset() {
    local repo="$(basename $PWD)"
    local remote="${1:-got}"
    local me=$(whoami)
    local user="${2:-${me}}"
    git remote -v | grep -F "$remote" && echo "Already there!" && return 0

    tea repo create --name "$repo" \
                                 && git remote add origin "git@${remote}:${2-${me}}/$repo" \
                                                           && git push --all
}
