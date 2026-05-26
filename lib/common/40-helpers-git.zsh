alias g=git

in_repo() {
    i_have git && git rev-parse HEAD &>/dev/null
}

git_worktree_swap() {
    local _left_branch="$(git branch --show-current)"
    local _left_dir="$(pwd)"
    local _right_branch="$1"
    local _right_dir="$(git_worktree_get_dir "$_right_branch")"
    [[ $? -eq 0 ]] || return 1
    echo "Detaching HEAD of $_left_dir"
    git checkout --detach
    [[ $? -eq 0 ]] || return 1
    cd "$_right_dir"
    echo "Swapping $_left_branch into $_right_dir"
    git checkout "$_left_branch"
    echo "Completing checkout of $_right_branch into $_left_dir"
    cd "$_left_dir"
    git checkout "$_right_branch"
}

git_worktree_get_dir() {
    local _desired_branch="$1"
    local _found="$(git worktree list --porcelain | grep -B 2 "branch refs/heads/${_desired_branch}" | grep "worktree" | cut -d' ' -f2)"
    if [ -d "$_found" ]; then
        echo "$_found"
    else
        echo "Worktree directory for '$_desired_branch' not found."
        return 1
    fi
}

git_worktree_cd() {
    git_worktree_get_dir "$1" && pushd "$(git_worktree_get_dir "$1")"
}

_git_branch_complete() {
    local -a branches
    # Get local branch names using git
    branches=(${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"})
    _describe 'branches' branches
}

# Register the function for your command
autoload -Uz compinit
compinit
compdef _git_branch_complete git_worktree_get_dir git_worktree_cd git_worktree_swap
