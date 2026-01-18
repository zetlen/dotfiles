alias g=git

in_repo() {
    i_have git && git rev-parse HEAD &>/dev/null
}

gworktree() {
    local branchname="$1"
    if [ -z "$branchname" ]; then
        echo "must provide branch name"
        return 1
    fi
    local reporoot="$(git rev-parse --show-toplevel)"
    local reponame="$(basename "$reporoot")"
    local worktreesgroupdir="../${reponame}.worktrees"
    cd "$reporoot"
    mkdir -p "$worktreesgroupdir"
    local worktreedir="${worktreesgroupdir}/${branchname}"
    git worktree add -b "$branchname" "$worktreedir" main
    cd "$worktreedir"
    mise trust
    mise install
}
