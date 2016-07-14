" Vundle Setup {{{

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
" Plugin 'user/L9', {'name': 'newL9'}
" }}}

" Colors {{{

set t_Co=256                         " 256 color terminal
set background=dark                  " because it's how i feel on the inside
syntax enable                        " all syntaces, forever!
Plugin 'flazz/vim-colorschemes'      " install a few more colorschemes

" }}}

" Spaces and Tabs {{{

set tabstop=2                            " visual spaces per tab
set shiftwidth=2                         " tab size of reindent > < operations
set expandtab                            " always spaces, everywhere, forever
set autoindent                           " guess smart indents
set smarttab                             " respond reasonably to tab key
Plugin 'editorconfig/editorconfig-vim'   " Use editorconfig
Plugin 'godlygeek/tabular'               " :Tabularize alignment command
Plugin 'nathanaelkane/vim-indent-guides' " indent guides on left
autocmd VimEnter * :IndentGuidesEnable   " turn it on by default
let g:indent_guides_auto_colors = 0

" }}}

" UI Chrome {{{

set encoding=utf-8     " show unicode chars
set noshowmode         " airline handles mode display
set number             " show line numbers
set relativenumber     " relative to current line
set wildmenu           " command autocomplete view
set lazyredraw         " supposedly for performance, revisit this
set showmatch          " show matching brackets
set noerrorbells       " quit beeping
set novisualbell       " i said, quit beeping
set t_vb=
Plugin 'sjl/gundo.vim' " visual undo

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
Plugin 'bling/vim-airline'        " powerline bottom bar, in vimscript only
let g:airline_powerline_fonts = 1 " use special fonts, not unicode simulations
let g:airline_mode_map = {
      \ '__' : '-',
      \ 'n'  : 'N',
      \ 'i'  : 'I',
      \ 'R'  : 'R',
      \ 'c'  : 'C',
      \ 'v'  : 'V',
      \ 'V'  : 'V',
      \ '' : 'V',
      \ 's'  : 'S',
      \ 'S'  : 'S',
      \ '' : 'S',
      \ }
let g:airline_exclude_preview = 1
let g:airline#extensions#branch#enabled = 0
let g:airline#extensions#syntastic#enabled = 0

" note that 'filetype plugin indent on' must be set after vundle is done
" otherwise that would be right here

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
Plugin 'tomtom/tcomment_vim'

" quickly toggle relativenumber
nnoremap <leader>n :set relativenumber!<cr>
vnoremap <leader>n :set relativenumber!<cr>

" better word wrap
set formatoptions=l
set lbr

" highlight last inserted text
nnoremap gV `[v`]

set backspace=indent,eol,start " backspace can move over lines
set whichwrap+=<,>,h,l         " left and right can move over lines

set nrformats-=octal           " don't assume 0-leader numbers are octal

set timeout                    " no weird delay in bindings
set timeoutlen=1000            " if weird delay is there, it's short
set ttimeoutlen=10             " no delay on escape, though.

if !&scrolloff
  set scrolloff=5              " at least 5 lines below my cursor
endif
if !&sidescrolloff
  set sidescrolloff=5          " at least five columns to the right of it
endif
set display+=lastline

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
" }}}

" Searching {{{

set incsearch  " search as characters are entered
set hlsearch   " hilight as characters are entered
set ignorecase " ignore case when searching
set smartcase  " but only ignore case when search is all lower case

" turn off search highlight
nnoremap <leader><space> :noh<cr>

" Silver Searcher and friends!
Plugin 'mileszs/ack.vim'
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
Plugin 'tpope/vim-fugitive' " git interactions

" mouse stuff
set mouse=a
set ttymouse=xterm2

" repl stuff
Plugin 'sjl/tslime.vim'
let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1
vnoremap <C-c><C-c> <Plug>SendSelectionToTmux
nnoremap <C-c><C-c> <Plug>NormalModeSendToTmux
nnoremap <C-c>r <Plug>SetTmuxVars

" }}}

" Netrw {{{

let g:netrw_banner=0                        " no banner
let g:netrw_preview=1                       " open previews vertically
let g:netrw_list_hide='.*\.swp$,.DS_Store$' " hide vim swp files and osx files
let g:netrw_altfile = 1                     " don't add netrw browsers to buffer list maybe
Plugin 'tpope/vim-vinegar'

" }}}

" Autocomplete {{{

if &history < 1000
  set history=1000            " more command history
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_key_list_select_completion = ["<TAB>","<Down>"]
Plugin 'Valloric/YouCompleteMe' " giving this a shot

Plugin 'Raimondi/delimitMate' " autocomplete brackets and quotes
let delimitMate_expand_cr = 1   " create closing brace on <cr>
let delimitMate_expand_space = 1
let delimitMate_excluded_ft = "mail,txt,ghmarkdown,markdown"  " exclude filetypes

Plugin 'tpope/vim-surround'

" }}}

" CtrlP Options {{{

let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|\.git\/'
Plugin 'ctrlpvim/ctrlp.vim' " plugin for Sublime Text-like CtrlP
nnoremap <leader><c-p> :CtrlPMRUFiles<cr>
let g:ctrlp_max_files = 25000

" }}}

" Syntastic {{{
Plugin 'scrooloose/syntastic.git'

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 1
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_sass_checkers=["sass_lint"]
let g:syntastic_scss_checkers=["sass_lint"]
" let g:syntastic_javascript_eslint_exec = 'eslint_d'
Plugin 'pmsorhaindo/syntastic-local-eslint.vim'

function! s:SyntaxSetup()
  let s:es6lintrc = findfile('.eslintes6rc')
  if filereadable(s:es6lintrc)
    let b:syntastic_javascript_eslint_args = "-c " . s:es6lintrc
  endif
endfunction

augroup syntaxcheckers
  au!
  au BufRead,BufNewFile,BufEnter *.es6 :call s:SyntaxSetup()
augroup END

" }}}

" Filetype: Hypr {{{

Plugin 'Glench/Vim-Jinja2-Syntax'
autocmd BufNewFile,BufReadPost *.hypr,*.hypr.live set filetype=jinja

" }}}

" Filetype: JavaScript {{{

Plugin 'jelera/vim-javascript-syntax' " syntax highlighting
Plugin 'gavocanov/vim-js-indent'      " indentation
Plugin 'mxw/vim-jsx'                  " JSX highlighting and indenting
Plugin 'maksimr/vim-jsbeautify'       " beautification



function! s:JsSetup()
  set background=dark
  set cc=80
  hi IndentGuidesEven guibg=#222222
  hi IndentGuidesOdd guibg=#272727
  hi TabChars guifg=#990000 ctermfg=red
  match TabChars /\t/
  hi NonText guifg=#990000 ctermfg=red
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

Plugin 'leafgarland/typescript-vim'

" }}}

" Filetype: JSON {{{

Plugin 'elzr/vim-json' " syntax highlighting

augroup json
  au!
  au FileType json :call s:JsSetup()
augroup END

" }}}

" Filetype: Less {{{

Plugin 'groenewege/vim-less' " syntax highlighting

augroup less
  au!
  au FileType less :call s:JsSetup()
augroup END

" }}}

" Filetype: Sass {{{

Plugin 'gcorne/vim-sass-lint' " syntastic plugin

" }}}

" Filetype: Jade {{{

Plugin 'digitaltoad/vim-jade.git'
autocmd BufNewFile,BufReadPost *.jade set filetype=jade

" }}}

" Filetype: DustJS {{{

Plugin 'jimmyhchan/dustjs.vim' " syntax highlighting
autocmd BufNewFile,BufReadPost *.dust,*.dustjs set filetype=dustjs

" }}}

" Filetype: Markdown {{{

Plugin 'tpope/vim-markdown' " syntax highlighting
Plugin 'suan/vim-instant-markdown'      " preview in realtime browser
let g:instant_markdown_autostart = 0    " don't launch a browser for each file!

" markdown mode requires this, see https://github.com/plasticboy/vim-markdown
let g:vim_markdown_folding_disabled=1

let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'javascript', 'scheme']

function! s:MarkdownMode()
  set background=light
  if exists("g:airline_section_a")
    AirlineTheme light
  endif
  set laststatus=2
  colorscheme PaperColor
endfunction

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

" Todo List {{{

Plugin 'zetlen/vim-simple-todo'
let g:simple_todo_tick_symbol = 'x'

" bind last search as foldmethod to hide and show certain tasks
nnoremap \] :setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2<CR>

" open todo list
command! Todo :e ~/Dropbox/todo.mdown | /\[ \]/

" }}}

" Vundle Cleanup {{{

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" }}}

" Color Scheme Default {{{
colorscheme apprentice
set laststatus=2
" }}}

" GUI Only Options {{{
" if has("gui_running")
"     set transparency=3
"     au GUIEnter * set fullscreen
" endif
" }}}

" Load Local {{{
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
" }}}
" vim:foldmethod=marker:foldlevel=0
