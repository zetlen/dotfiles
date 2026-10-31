" ~/.vimrc -- plain vim, deliberately lightweight.
"
" Preferences are NOT defined here. They live in ~/.dotfiles/lib/vim/common/
" and are shared verbatim with the heavier neovim setup in
" ~/.config/nvim/init.lua, so both editors look and behave the same.
"
" Only put things here that plain vim alone can use: terminal-control options
" neovim doesn't implement, vim's optional bundled packages, and the vim-plug
" plugin set.

" Shared preferences {{{

" Sourced before plug#end() so <leader> is defined before any plugin builds its
" mappings.
let s:dotfiles = !empty($DOTFILE_PATH) ? $DOTFILE_PATH : expand('~/.dotfiles')
execute 'source' fnameescape(s:dotfiles . '/lib/vim/common.vim')

" }}}

" Vim-only options {{{

" neovim rejects or does not need every option in this block: ttymouse errors
" outright (E518), neovim turns on 'termguicolors' itself when the terminal
" supports it, and the t_ escapes are dead weight there because neovim drives
" cursor shape through 'guicursor' natively.
if $COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit'
  set termguicolors            " exact colorscheme colors, matching neovim
endif
set ttymouse=sgr

" Bar cursor in insert mode, block elsewhere, via the DECSCUSR escape that
" terminals and multiplexers understand without passthrough wrapping.
let &t_SI = "\<Esc>[6 q"
let &t_EI = "\<Esc>[2 q"

" Over SSH, yanks reach the local machine's clipboard through OSC 52, the
" terminal escape sequence for writing the clipboard. The osc52 package needs
" vim 9.1.1984 or later, which mise installs (conf.d/20-utils.toml). Support
" detection is skipped because it relies on a terminal query that
" multiplexers may not pass along. Paste is off because that query blocks on
" every `p` when the terminal does not answer; text copied on the local
" machine comes in through the terminal's own paste key.
if !empty($SSH_TTY) && has('clipboard_provider')
  let g:osc52_force_avail = 1
  let g:osc52_disable_paste = 1
  packadd osc52
  set clipmethod=osc52
endif

" }}}

" Plugin Setup {{{

let data_dir = '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Bundled with vim but opt-in. neovim has both built in.
packadd! editorconfig                  " use .editorconfig
packadd! comment                       " gc/gcc commenting

call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-surround'              " surround commands (ysiw{ csa{[ etc)
Plug 'tpope/vim-fugitive'              " git interactions
Plug 'tpope/vim-vinegar'               " netrw, improved

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
