" Minimal {{{
set laststatus=2
set statusline=
set statusline+=%2*
set statusline+=%{mode(1)}
set statusline+=%1*
set statusline+=\ 
set statusline+=»
set statusline+=%=
set statusline+=%m
set statusline+=%h
set statusline+=%r
set statusline+=\ 
set statusline+=%3*
set statusline+=%1*
set statusline+=\ 
set statusline+=%4*
set statusline+=%F
set statusline+=\ 
set statusline+=»
set statusline+=\ 
set statusline+=%5*
set statusline+=%l
set statusline+=/
set statusline+=%L
set statusline+=%1*
set statusline+=\ 
set statusline+=»
set statusline+=\ 
set statusline+=|
set statusline+=%y

function! StatuslineMode()
  let l:mode=mode()
  if l:mode==#"n"
    return "NORMAL"
  elseif l:mode==?"v"
    return "VISUAL"
  elseif l:mode==#"i"
    return "INSERT"
  elseif l:mode==#"R"
    return "REPLACE"
  elseif l:mode==?"s"
    return "SELECT"
  elseif l:mode==#"t"
    return "TERMINAL"
  elseif l:mode==#"c"
    return "COMMAND"
  elseif l:mode==#"!"
    return "SHELL"
  endif
endfunction

" }}}
" Plugin Setup {{{

call plug#begin('~/.vim/plugged')

" }}}

" Colors {{{

set t_Co=256                         " 256 color terminal
set background=dark                  " because it's how i feel on the inside
syntax enable                        " all syntaces, forever!
Plug 'flazz/vim-colorschemes'      " install a few more colorschemes

" }}}

" Spaces and Tabs {{{

set tabstop=2                            " visual spaces per tab
set shiftwidth=2                         " tab size of reindent > < operations
set expandtab                            " always spaces, everywhere, forever
set autoindent                           " guess smart indents
set smarttab                             " respond reasonably to tab key
Plug 'editorconfig/editorconfig-vim'   " Use editorconfig
Plug 'godlygeek/tabular'               " :Tabularize alignment command
Plug 'nathanaelkane/vim-indent-guides' " indent guides on left
let g:indent_guides_auto_colors = 0

" }}}

" UI Chrome {{{

set encoding=utf-8     " show unicode chars
set noshowmode         " airline handles mode display
set number             " show line numbers
" set relativenumber     " relative to current line
set wildmenu           " command autocomplete view
set lazyredraw         " supposedly for performance, revisit this
set showmatch          " show matching brackets
set noerrorbells       " quit beeping
set novisualbell       " i said, quit beeping
set t_vb=
Plug 'sjl/gundo.vim' " visual undo

if &tabpagemax < 50
  set tabpagemax=50    " reasonable tab limit
endif

if !empty(&viminfo)
  set viminfo^=!       " better startup and shutdown
endif

set sessionoptions-=options " don't export every option to new sessions

set list
if &listchars ==# 'eol:$'
  set listchars=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:+ " extra listchars
endif

" Airline!
" Plug 'bling/vim-airline'        " powerline bottom bar, in vimscript only
" let g:airline_powerline_fonts = 1 " use special fonts, not unicode simulations
" let g:airline_mode_map = {
"       \ '__' : '-',
"       \ 'n'  : 'N',
"       \ 'i'  : 'I',
"       \ 'R'  : 'R',
"       \ 'c'  : 'C',
"       \ 'v'  : 'V',
"       \ 'V'  : 'V',
"       \ '' : 'V',
"       \ 's'  : 'S',
"       \ 'S'  : 'S',
"       \ '' : 'S',
"       \ }
" let g:airline_exclude_preview = 1
" let g:airline#extensions#branch#enabled = 0
" let g:airline#extensions#syntastic#enabled = 0
" filetype plugin indent on

" }}}

" Movement and Keybindings {{{

let mapleader = ","   "<leader> is comma
let g:mapleader = "," "<leader> is comma everywhere

nnoremap j gj
nnoremap k gk

vnoremap ;; <Esc>
inoremap ;; <Esc>

" switch quickly between buffers
nnoremap <leader>; :b#<cr>
vnoremap <leader>; <esc>:b#<cr>
inoremap <leader>; <esc>:b#<cr>

" ,/ and ,? find blank lines
nnoremap <leader>/ /^\s*$<cr>:noh<cr>
vnoremap <leader>/ /^\s*$<cr>:noh<cr>
nnoremap <leader>? ?^\s*$<cr>:noh<cr>
vnoremap <leader>? ?^\s*$<cr>:noh<cr>

" quickly kill quickfixes and loclists
noremap <leader>c :windo lcl\|ccl<cr>

" commenting code
Plug 'tomtom/tcomment_vim'

" quickly toggle relativenumber
nnoremap <leader>n :set relativenumber!<cr>
vnoremap <leader>n :set relativenumber!<cr>

" better word wrap
set formatoptions=l
set lbr

" highlight last inserted text
nnoremap gV `[v`]

" make regexes very magic all the time
" thus enabling modern regex features
nnoremap / /\v
vnoremap / /\v


set backspace=indent,eol,start " backspace can move over lines
set whichwrap+=<,>,h,l         " left and right can move over lines

set nrformats-=octal           " don't assume 0-leader numbers are octal

set timeout                    " no weird delay in bindings
set timeoutlen=100            " if weird delay is there, it's short
set ttimeoutlen=10             " no delay on escape, though.

if !&scrolloff
  set scrolloff=5              " at least 5 lines below my cursor
endif
if !&sidescrolloff
  set sidescrolloff=5          " at least five columns to the right of it
endif
set display+=lastline

" bar cursor for insert mode
if exists('$TMUX')
	let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
	let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
	let &t_SI = "\<Esc>]50;CursorShape=1\x7"
	let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" don't close window when deleting buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction
" get higroups under line
map <leader>h :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" make splits go down and right
set splitbelow
set splitright

" }}}

" Searching {{{

set incsearch  " search as characters are entered
set hlsearch   " hilight as characters are entered
set ignorecase " ignore case when searching
set smartcase  " but only ignore case when search is all lower case

" turn off search highlight
nnoremap <leader><space> :noh<cr>

" Silver Searcher and friends!
Plug 'mileszs/ack.vim'
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" }}}

" OS Interoperation {{{

set hidden                  " allow hidden buffers with changes
set clipboard=unnamed       " clipboard interacts with OS
set autoread                " respond smoothly to file changes
augroup checktime
    au!
    if !has("gui_running")
        "silent! necessary otherwise throws errors when using command
        "line window.
        autocmd BufEnter        * silent! checktime
        autocmd CursorHold      * silent! checktime
        autocmd CursorHoldI     * silent! checktime
        "these two _may_ slow things down. Remove if they do.
        autocmd CursorMoved     * silent! checktime
        autocmd CursorMovedI    * silent! checktime
    endif
augroup END
set nobackup                " Backup is what Time Machine is for
set nowb                    " Don't write backup file
set noswapfile              " Boy are .swps annoying huh
Plug 'tpope/vim-fugitive' " git interactions
" Plug 'tmux-plugins/vim-tmux-focus-events'

" mouse stuff
set mouse=a
set ttymouse=xterm2

" repl stuff
" Plug 'sjl/tslime.vim'
" let g:tslime_always_current_session = 1
" let g:tslime_always_current_window = 1
" vnoremap <C-c><C-c> <Plug>SendSelectionToTmux
" nnoremap <C-c><C-c> <Plug>NormalModeSendToTmux
" nnoremap <C-c>r <Plug>SetTmuxVars

" }}}

" Netrw {{{

let g:netrw_banner=0                        " no banner
let g:netrw_preview=1                       " open previews vertically
let g:netrw_list_hide='.*\.swp$,.DS_Store$' " hide vim swp files and osx files
let g:netrw_altfile = 1                     " don't add netrw browsers to buffer list maybe
Plug 'tpope/vim-vinegar'

" }}}

" Autocomplete {{{

if &history < 1000
  set history=1000            " more command history
endif

" " Load matchit.vim, but only if the user hasn't installed a newer version.
" if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
"   runtime! macros/matchit.vim
" endif
"
" let g:ycm_autoclose_preview_window_after_completion = 1
" let g:ycm_autoclose_preview_window_after_insertion = 1
" let g:ycm_key_list_select_completion = ["<TAB>","<Down>"]
" function! BuildYCM(info)
"   if a:info.status == 'installed' || a:info.force
"     !./install.py --tern-completer
"   endif
" endfunction
" Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
"
" Plug 'Raimondi/delimitMate' " autocomplete brackets and quotes
" let delimitMate_expand_cr = 1   " create closing brace on <cr>
" let delimitMate_expand_space = 1
" let delimitMate_excluded_ft = "mail,txt,ghmarkdown,markdown"  " exclude filetypes

Plug 'tpope/vim-surround'

" }}}

" CtrlP Options {{{

" let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|\.build\|\.git\/'
" Plug 'ctrlpvim/ctrlp.vim' " plugin for Sublime Text-like CtrlP
" nnoremap <leader><c-p> :CtrlPMRUFiles<cr>
" let g:ctrlp_max_files = 25000

" }}}

" Syntastic {{{
Plug 'vim-syntastic/syntastic'
"
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 0
" let g:syntastic_check_on_wq = 1
" let g:syntastic_javascript_checkers = ['eslint']
" let g:syntastic_typescript_tsc_fname = ''
" let g:syntastic_sass_checkers=["sass_lint"]
" let g:syntastic_scss_checkers=["sass_lint"]
" " let g:syntastic_javascript_eslint_exec = 'eslint_d'
" Plug 'pmsorhaindo/syntastic-local-eslint.vim'
"
" function! s:SyntaxSetup()
"   let s:es6lintrc = findfile('.eslintes6rc')
"   if filereadable(s:es6lintrc)
"     let b:syntastic_javascript_eslint_args = "-c " . s:es6lintrc
"   endif
" endfunction
"
" augroup syntaxcheckers
"   au!
"   au BufRead,BufNewFile,BufEnter *.es6 :call s:SyntaxSetup()
" augroup END
"
" }}}

" Filetype: JavaScript {{{

Plug 'jelera/vim-javascript-syntax' " syntax highlighting
Plug 'gavocanov/vim-js-indent'      " indentation
Plug 'mxw/vim-jsx'                  " JSX highlighting and indenting
" Plug 'maksimr/vim-jsbeautify'       " beautification



function! s:JsSetup()
  set background=dark
  set cc=100
  hi IndentGuidesEven guibg=#121212 guifg=#121212 ctermbg=233 ctermfg=233
  hi IndentGuidesOdd guibg=#1c1c1c guifg=#1c1c1c ctermbg=232 ctermfg=232
  if exists("g:airline_section_a")
    AirlineTheme dark
  endif
  nnoremap <buffer> gd :YcmCompleter GoToDefinition<cr>
  nnoremap <buffer> gr :YcmCompleter GoToReferences<cr>
  nnoremap <buffer> gR :YcmCompleter RefactorRename<space>
  vnoremap <buffer>  <c-f> :call RangeJsBeautify()<cr>
endfunction

augroup javascript
  au!
  au BufRead,BufNewFile,BufEnter *.js,*.es6 :setf javascript
  au FileType javascript :call s:JsSetup()
augroup END

" }}}

" Filetype: TypeScript {{{

Plug 'leafgarland/typescript-vim' " syntax highlighting
autocmd BufNewFile,BufRead *.ts,*.tsx setlocal filetype=typescript

" }}}

" Filetype: JSON {{{

" Plug 'elzr/vim-json' " syntax highlighting
"
" augroup json
"   au!
"   au FileType json :call s:JsSetup()
" augroup END

" }}}

" Filetype: Less {{{

" Plug 'groenewege/vim-less' " syntax highlighting
"
" augroup less
"   au!
"   au FileType less :call s:JsSetup()
" augroup END

" }}}

" Filetype: Sass {{{

" Plug 'gcorne/vim-sass-lint' " syntastic plugin

" }}}

" Filetype: Markdown {{{

" Plug 'tpope/vim-markdown' " syntax highlighting
" Plug 'suan/vim-instant-markdown'      " preview in realtime browser
" let g:instant_markdown_autostart = 0    " don't launch a browser for each file!

" markdown mode requires this, see https://github.com/plasticboy/vim-markdown
" let g:vim_markdown_folding_disabled=1
"
" let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'javascript', 'scheme']
"
" function! s:MarkdownMode()
"   " set background=light
"   " if exists("g:airline_section_a")
"   "   AirlineTheme light
"   " endif
"   " set laststatus=2
"   colorscheme Pencil
" endfunction

augroup markdown
  au!
  au BufNewFile,BufRead,BufEnter *.mdown,*.md,*.markdown :setf markdown
  au FileType markdown :call s:MarkdownMode()
augroup END

" }}}

" Filetype: Scheme {{{

function! s:SchemeRacketMode()
  set filetype=scheme
  set lisp
endfunction

augroup scheme
  au!
  au BufNewFile,BufReadPost,BufEnter *.rkt,*.rktl :call s:SchemeRacketMode()
augroup END

" }}}

" Other Filetypes {{{

" Plug 'vito-c/jq.vim'
" autocmd BufNewFile,BufReadPost *.taskrc set filetype=taskrc
" autocmd BufNewFile,BufReadPost *.bashrc set filetype=sh
" let g:is_bash = 1

" }}}

" Plugin Cleanup {{{

" All of your Plugins must be added before the following line
call plug#end()

" }}}

" Color Scheme Default {{{
try
  colorscheme Tomorrow-Night-Bright
catch /^Vim\%((\a\+)\)\=:E185/
    " deal with it
endtry
set laststatus=2
" }}}

" GUI Only Options {{{
" if has("gui_running")
"     set transparency=3
" 	set guifont=Input:h12
" 	set linespace=2
" endif
" }}}

" Load Local {{{
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
" }}}
" vim:foldmethod=marker:foldlevel=0
