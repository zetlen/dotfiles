" Spaces and tabs. editorconfig overrides these per-project in both editors.

set tabstop=2                            " visual spaces per tab
set shiftwidth=2                         " tab size of reindent > < operations
set expandtab                            " always spaces, everywhere, forever
set autoindent                           " guess smart indents
set smarttab                             " respond reasonably to tab key

" Indent guides, off by default. <leader>ig toggles a guide every 'shiftwidth'
" columns of leading spaces in the current window. They are drawn through
" 'listchars' leadmultispace, which only displays because 40-ui.vim sets
" 'list'. Toggle again after changing 'shiftwidth' to re-space them.
function! s:ToggleIndentGuides()
  if &l:listchars =~# 'leadmultispace'
    setlocal listchars<
  else
    let &l:listchars = &g:listchars . ',leadmultispace:│' . repeat(' ', shiftwidth() - 1)
  endif
endfunction
nnoremap <silent> <leader>ig :call <SID>ToggleIndentGuides()<CR>
