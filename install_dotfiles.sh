for file in {.,}*; do [ -f "$file" ] && ln -s $(pwd)/"$file" ~/"$file"; done
if [ ! -f ~/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
