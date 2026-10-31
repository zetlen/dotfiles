" Per-filetype settings shared by both editors. Filetype detection, syntax and
" indent come from each editor's bundled runtime.

" Filetype: JavaScript {{{

augroup javascript
  au!
  au FileType javascript set background=dark | setlocal colorcolumn=100
augroup END

" }}}
" vim:foldmethod=marker:foldlevel=0
