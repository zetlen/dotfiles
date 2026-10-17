alias y='yarn '
alias yr='yarn run '
alias p='pnpm '
alias pr='pnpm run '
alias prr='pnpm run -r '
alias prip='pnpm run -r --if-present '
alias prf='pnpm run --filter '
alias pripf='pnpm run --if-present --filter '
alias b='bun '
alias br='bun run'
alias delete_node_modules='find . -name "node_modules" -type d -prune -exec rm -rf '{}' +'
alias nenv='printf "node %s\n%s %s\n" "$(node -v)" na "$(na --version)"'
alias nreset='clean_project; delete_node_modules; ni;'

clean_node_project() {
    nr --if-present clean && in_repo && git wash
    return 0
}
