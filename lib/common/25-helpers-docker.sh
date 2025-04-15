alias docker-compose="docker compose "
alias dco="docker compose "
alias dcou="dco up --wait --wait-timeout 10 -d "
alias dcouf="docker compose pull && dcou --force-recreate "

dsh() {
    docker exec -it $1 ${2:-bash}
}
