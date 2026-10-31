" Searching.

set incsearch  " search as characters are entered
set hlsearch   " hilight as characters are entered
set ignorecase " ignore case when searching
set smartcase  " but only ignore case when search is all lower case

" turn off search highlight
nnoremap <leader><space> :noh<cr>

" Navigate quickfix list with ease
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> ]q :cnext<CR>

" :grep with ripgrep, matching VS Code's default scope: honor .gitignore, but
" include dotfiles except .git. Neovim's own rg default adds -uu, which also
" searches node_modules and build output; plain vim's default is grep -n.
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden\ --glob=!.git
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

" :Cfilter /pat/ and :Cfilter! /pat/ narrow the quickfix list; :Lfilter does
" the same for location lists. Bundled with vim 8.1+ and neovim, off by default.
silent! packadd cfilter
