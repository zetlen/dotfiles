" ~/.vimrc -- plain vim, deliberately lightweight.
"
" Preferences are NOT defined here. They live in ~/.dotfiles/lib/vim/common/
" and are shared verbatim with the heavier neovim setup in
" ~/.config/nvim/init.lua, so both editors look and behave the same.
"
" Only put things here that plain vim alone can use: terminal-control options
" neovim doesn't implement, and the vim-plug plugin set.

" Shared preferences {{{

" Sourced before plug#end() so <leader> is defined before any plugin builds its
" mappings.
let s:dotfiles = !empty($DOTFILE_PATH) ? $DOTFILE_PATH : expand('~/.dotfiles')
execute 'source' fnameescape(s:dotfiles . '/lib/vim/common.vim')

" }}}

" Vim-only options {{{

" neovim rejects or ignores every option in this block: ttymouse and
" pastetoggle error outright (E518/E519), and the t_ escapes are dead weight
" there because neovim drives cursor shape through 'guicursor' natively.
set t_Co=256                   " 256 color terminal
set t_vb=                      " no visual bell, for real this time
set ttymouse=xterm2
set pastetoggle=<leader>p      " enter paste mode with ,p

" bar cursor for insert mode
if exists('$TMUX') || exists('$ZELLIJ') || exists('$HERDR')
	let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
	let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
	let &t_SI = "\<Esc>]50;CursorShape=1\x7"
	let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" }}}

" Plugin Setup {{{

let data_dir = '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'imsnif/kdl.vim'                  " kdl syntax
Plug 'editorconfig/editorconfig-vim'   " Use editorconfig
Plug 'nathanaelkane/vim-indent-guides' " indent guides on left
Plug 'tomtom/tcomment_vim'             " commenting code
Plug 'tpope/vim-surround'              " surround commands (ysiw{ csa{[ etc)
Plug 'tpope/vim-fugitive'              " git interactions
Plug 'tpope/vim-vinegar'               " netrw, improved

" Filetypes. neovim uses treesitter for these instead.
Plug 'jelera/vim-javascript-syntax'    " syntax highlighting
Plug 'gavocanov/vim-js-indent'         " indentation
Plug 'mxw/vim-jsx'                     " JSX highlighting and indenting
Plug 'leafgarland/typescript-vim'      " syntax highlighting

Plug 'joshdick/onedark.vim'

" }}}

" Load Local {{{
" Before plug#end() so ~/.vimrc.local can still add Plug lines.
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
" }}}

" Plugin Cleanup {{{

" All of your Plugins must be added before the following line
call plug#end()

" }}}

" Color Scheme Default {{{
try
  colorscheme onedark
catch /^Vim\%((\a\+)\)\=:E185/
    " deal with it
endtry
set laststatus=2
" }}}

" vim:foldmethod=marker:foldlevel=0
