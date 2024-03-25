teaset() {
  local repo="$(basename $PWD)"
  local remote="${1:-got.in.the-z-machine.com}"
  local user="${2:-zetlen}"
  git remote -v | grep -F "$remote" && echo "Already there!" && return 0

  tea repo create --name "$repo" && \
    git remote add origin "git@${remote}:${2-zetlen}/$repo" && \
    git push --all
}
