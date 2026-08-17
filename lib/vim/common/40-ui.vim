" UI chrome.

set encoding=utf-8     " show unicode chars
set noshowmode         " statusline handles mode display
set number             " show line numbers
set relativenumber     " relative to current line, except in insert mode (see below)

" Relative numbers are great for jump/motion commands in normal mode, but
" useless (and distracting) while typing in insert mode, so switch to
" absolute numbering for the duration of insert mode only.
function! s:ToggleRelativeNumber(insert) abort
  if a:insert
    set norelativenumber
  else
    set relativenumber
  endif
endfunction

augroup relnumber_insert_toggle
  autocmd!
  autocmd InsertEnter * call s:ToggleRelativeNumber(v:true)
  autocmd InsertLeave * call s:ToggleRelativeNumber(v:false)
augroup END
set wildmenu           " command autocomplete view
set lazyredraw         " supposedly for performance, revisit this
set showmatch          " show matching brackets
set noerrorbells       " quit beeping
set belloff=all        " really, quit beeping
set novisualbell       " i said, quit beeping

if &tabpagemax < 50
  set tabpagemax=50    " reasonable tab limit
endif

if !empty(&viminfo)
  set viminfo^=!       " better startup and shutdown
endif

set sessionoptions-=options " don't export every option to new sessions

set list
" Set unconditionally rather than the usual `if &listchars ==# 'eol:$'` guard.
" That guard means "only if still at the default", but the default differs by
" engine -- vim ships 'eol:$', neovim ships 'tab:> ,trail:-,nbsp:+' -- so the
" guarded form silently skipped neovim and the two editors drew tabs
" differently. In plain vim the result is identical either way.
set listchars=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:+ " extra listchars
