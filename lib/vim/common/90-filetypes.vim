" Filetype detection and per-filetype tweaks. Syntax/indent *plugins* are
" declared per-editor (vim uses vim-plug packages, nvim uses treesitter), but
" the detection rules and local settings belong to both.

" Filetype: JavaScript {{{

function! s:JsSetup()
  set background=dark
  set cc=100
  " no-ops unless vim-indent-guides is loaded; harmless in nvim
  hi IndentGuidesEven guibg=#121212 guifg=#121212 ctermbg=233 ctermfg=233
  hi IndentGuidesOdd guibg=#1c1c1c guifg=#1c1c1c ctermbg=232 ctermfg=232
endfunction

augroup javascript
  au!
  au BufRead,BufNewFile,BufEnter *.js,*.mjs,*.cjs :setf javascript
  au FileType javascript :call s:JsSetup()
augroup END

" }}}

" Filetype: TypeScript {{{

augroup typescript
	au!
	au BufRead,BufNewFile,BufEnter *.ts,*.tsx :setf typescript
augroup END

" }}}

" Filetype: JSON {{{

augroup jsoncFtdetect
  autocmd!

  " Recognize some extensions known to have JSON with comments
  " Note: If conflicts are found, please report them.

  " https://github.com/mohae/cjson
  autocmd BufNewFile,BufRead *.cjsn setfiletype jsonc
  " https://github.com/mohae/cjson
  autocmd BufNewFile,BufRead *.cjson setfiletype jsonc
  " https://github.com/Microsoft/vscode/issues/48969
  " https://komkom.github.io/
  " https://github.com/mochajs/mocha/issues/3753
  autocmd BufNewFile,BufRead *.jsonc setfiletype jsonc

  " Recognize some files known to support JSON with comments
  " Entries sorted by pattern

  " https://eslint.org/docs/user-guide/configuring
  autocmd BufNewFile,BufRead .eslintrc.json setlocal filetype=jsonc
  " https://jshint.com/docs/
  " https://github.com/neoclide/coc.nvim
  autocmd BufNewFile,BufRead coc-settings.json setlocal filetype=jsonc
  " https://github.com/microsoft/TypeScript/pull/5450
  autocmd BufNewFile,BufRead tsconfig.json setlocal filetype=jsonc
  " https://github.com/Alexays/Waybar/wiki/Configuration
  autocmd BufNewFile,BufRead */waybar/config setlocal filetype=jsonc
augroup END

" }}}
" vim:foldmethod=marker:foldlevel=0
