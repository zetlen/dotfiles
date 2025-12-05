teaset() {
    local repo="$(basename $PWD)"
    local remote="${1:-https://got.colonpipe.org}"
    local me=$(whoami)
    local user="${2:-${me}}"
    git remote -v | grep -F "$remote" && echo "Already there!" && return 0

    tea repos create --name "$repo" &&
        git remote add origin "git@${remote}:${2-${me}}/$repo" &&
        git push --all
}
