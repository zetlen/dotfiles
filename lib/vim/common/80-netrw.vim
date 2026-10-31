" Netrw is the file browser in both editors -- no tree plugin. vim-vinegar
" builds netrw's hide list from 'wildignore' and turns off the banner.

set wildignore+=.DS_Store
let g:netrw_preview=1                       " open previews vertically
let g:netrw_altfile = 1                     " don't add netrw browsers to buffer list maybe
