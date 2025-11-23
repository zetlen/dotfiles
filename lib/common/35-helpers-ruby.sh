alias bdx="bundle exec "
alias bdi="bundle install "
alias bdr="bin/rails "

puma-sites() {
    (
        printf 'HOST\tPROJECT\n'
        for app in $HOME/.puma-dev/*.*; do printf 'https://%s.test\t%s\n' $(basename $app) $(readlink -f $app | xargs basename); done
    ) | column -t -c '\t' | sed "1s/.*/$(tput bold)&$(tput sgr0)/"
}

ruby_get_report() {
    ls -t ~/Library/Logs/DiagnosticReports/ruby* | head -n 1 | xargs -n 1 realpath | xargs open
}
