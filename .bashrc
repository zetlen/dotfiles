# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/travis/travis.sh

export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$PATH:$HOME/.composer/vendor/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# BEGIN SNIPPET: Magento Cloud CLI configuration
HOME=${HOME:-'/Users/jzetlen'}
export PATH="$HOME/"'.magento-cloud/bin':"$PATH"
if [ -f "$HOME/"'.magento-cloud/shell-config.rc' ]; then . "$HOME/"'.magento-cloud/shell-config.rc'; fi # END SNIPPET
