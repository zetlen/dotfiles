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
