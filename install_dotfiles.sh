for file in {.,}*; do [ -f "$file" ] && ln -s $(pwd)/"$file" ~/"$file" 2> /dev/null; done
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim;
fi
