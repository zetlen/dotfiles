alias bx="bundle exec " 
alias bi="bundle install "
alias ba="bundle add "
alias br="bin/rails "

puma-sites() {
	(printf 'HOST\tPROJECT\n'; for app in $HOME/.puma-dev/*.*; do printf 'https://%s.test\t%s\n' $(basename $app) $(readlink -f $app | xargs basename); done) | column -t -c '\t' | sed "1s/.*/$(tput bold)&$(tput sgr0)/"
}
