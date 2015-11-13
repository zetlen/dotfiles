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

set t_Co=256                    " 256 color terminal
set background=dark             " because it's how i feel on the inside
syntax enable                   " all syntaces, forever!
Plugin 'flazz/vim-colorschemes' " install a few more colorschemes

" }}}

" Spaces and Tabs {{{

set tabstop=2                            " visual spaces per tab
set shiftwidth=2                         " tab size of reindent > < operations
set expandtab                            " always spaces, everywhere, forever
set autoindent                           " guess smart indents
set smarttab                             " respond reasonably to tab key
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
set tm=250
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
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+ " extra listchars
endif

" Airline!
Plugin 'bling/vim-airline'        " powerline bottom bar, in vimscript only
let g:airline_powerline_fonts = 1 " use special fonts, not unicode simulations

" note that 'filetype plugin indent on' must be set after vundle is done
" otherwise that would be right here

" }}}

" Movement and Keybindings {{{

let mapleader = ","   "<leader> is comma
let g:mapleader = "," "<leader> is comma everywhere

" let's get rid of some bad habits

fun! HabitNag()
  echo "no bad habits. ':call BadHabits()' to exit"
endfun

fun! NoBadHabits()

  vnoremap <buffer> h <Esc>:call HabitNag()<CR>
  vnoremap <buffer> j <Esc>:call HabitNag()<CR>
  vnoremap <buffer> k <Esc>:call HabitNag()<CR>
  vnoremap <buffer> l <Esc>:call HabitNag()<CR>

  " Display line motions
  vnoremap <buffer> gj <Esc>:call HabitNag()<CR>
  vnoremap <buffer> gk <Esc>:call HabitNag()<CR>
  nnoremap <buffer> gk <Esc>:call HabitNag()<CR>
  nnoremap <buffer> gj <Esc>:call HabitNag()<CR>

  nnoremap <buffer> h <Esc>:call HabitNag()<CR>
  nnoremap <buffer> j <Esc>:call HabitNag()<CR>
  nnoremap <buffer> k <Esc>:call HabitNag()<CR>
  nnoremap <buffer> l <Esc>:call HabitNag()<CR>

  nnoremap <buffer> <Left> <Esc>:call HabitNag()<CR>
  nnoremap <buffer> <Right> <Esc>:call HabitNag()<CR>
  nnoremap <buffer> <Up> <Esc>:call HabitNag()<CR>
  nnoremap <buffer> <Down> <Esc>:call HabitNag()<CR>
  nnoremap <buffer> <PageUp> <Esc>:call HabitNag()<CR>
  nnoremap <buffer> <PageDown> <Esc>:call HabitNag()<CR>

  inoremap <buffer> <Left> <Esc>:call HabitNag()<CR>
  inoremap <buffer> <Right> <Esc>:call HabitNag()<CR>
  inoremap <buffer> <Up> <Esc>:call HabitNag()<CR>
  inoremap <buffer> <Down> <Esc>:call HabitNag()<CR>
  inoremap <buffer> <PageUp> <Esc>:call HabitNag()<CR>
  inoremap <buffer> <PageDown> <Esc>:call HabitNag()<CR>

  vnoremap <buffer> <Left> <Esc>:call HabitNag()<CR>
  vnoremap <buffer> <Right> <Esc>:call HabitNag()<CR>
  vnoremap <buffer> <Up> <Esc>:call HabitNag()<CR>
  vnoremap <buffer> <Down> <Esc>:call HabitNag()<CR>
  vnoremap <buffer> <PageUp> <Esc>:call HabitNag()<CR>
  vnoremap <buffer> <PageDown> <Esc>:call HabitNag()<CR>

endfun

fun! BadHabits()

  set backspace=indent,eol,start

  silent! nunmap <buffer> <Left>
  silent! nunmap <buffer> <Right>
  silent! nunmap <buffer> <Up>
  silent! nunmap <buffer> <Down>
  silent! nunmap <buffer> <PageUp>
  silent! nunmap <buffer> <PageDown>

  silent! iunmap <buffer> <Left>
  silent! iunmap <buffer> <Right>
  silent! iunmap <buffer> <Up>
  silent! iunmap <buffer> <Down>
  silent! iunmap <buffer> <PageUp>
  silent! iunmap <buffer> <PageDown>

  silent! vunmap <buffer> <Left>
  silent! vunmap <buffer> <Right>
  silent! vunmap <buffer> <Up>
  silent! vunmap <buffer> <Down>
  silent! vunmap <buffer> <PageUp>
  silent! vunmap <buffer> <PageDown>

  silent! vunmap <buffer> h
  silent! vunmap <buffer> j
  silent! vunmap <buffer> k
  silent! vunmap <buffer> l
  silent! vunmap <buffer> +

  silent! nunmap <buffer> h
  silent! nunmap <buffer> j
  silent! nunmap <buffer> k
  silent! nunmap <buffer> l
  silent! nunmap <buffer> +

  " respect word wrap when moving up and down lines
  nnoremap j gj
  nnoremap k gk

endfun

" autocmd VimEnter,BufNewFile,BufReadPost * silent! call NoBadHabits()

" ,/ and ,? find blank lines
nnoremap <leader>/ /^\s*$<cr>:noh<cr>
vnoremap <leader>/ /^\s*$<cr>:noh<cr>
nnoremap <leader>? ?^\s*$<cr>:noh<cr>
vnoremap <leader>? ?^\s*$<cr>:noh<cr>

" commenting code
Plugin 'tomtom/tcomment_vim'

" quickly toggle relativenumber
nnoremap <leader>n :set relativenumber!<cr>
vnoremap <leader>n :set relativenumber!<cr>

" highlight last inserted text
nnoremap gV `[v`]

set backspace=indent,eol,start " backspace can move over lines
set whichwrap+=<,>,h,l         " left and right can move over lines

set nrformats-=octal           " don't assume 0-leader numbers are octal

set ttimeout                   " no weird delay in bindings
set ttimeoutlen=250            " if weird delay is there, it's short

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

" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :call VisualSelection('f')<CR>
vnoremap <silent> # :call VisualSelection('b')<CR>

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

" }}}

" Netrw {{{

" let g:netrw_browse_split=4
" let g:netrw_liststyle=1                     " thin (change to 3 for tree)
let g:netrw_banner=0                        " no banner
" let g:netrw_altv=1                          " open files on right
let g:netrw_preview=1                       " open previews vertically
let g:netrw_list_hide='.*\.swp$,.DS_Store$' " hide vim swp files and osx files
" let g:netrw_winsize = -28                   " good size
Plugin 'tpope/vim-vinegar'

" maybe never mind to this. project drawers aren't good with split windows.
" com!  -nargs=* -bar -bang -complete=dir  Lexplore  call netrw#Lexplore(<q-args>, <bang>0)
"
" fun! Lexplore(dir)
"   if exists("t:netrw_lexbufnr")
"   " close down netrw explorer window
"   let lexwinnr = bufwinnr(t:netrw_lexbufnr)
"   if lexwinnr != -1
"     let curwin = winnr()
"     exe lexwinnr."wincmd w"
"     close
"     exe curwin."wincmd w"
"   endif
"   unlet t:netrw_lexbufnr
"
"   else
"     " open netrw explorer window in the dir of current file
"     " (even on remote files)
"     let path = substitute(exists("b:netrw_curdir")? b:netrw_curdir : expand("%:p"), '^\(.*[/\\]\)[^/\\]*$','\1','e')
"     exe "topleft vertical ".((g:netrw_winsize > 0)? (g:netrw_winsize*winwidth(0))/100 : -g:netrw_winsize) . " new"
"     if a:dir != ""
"       exe "Explore ".a:dir
"     else
"       exe "Explore ".path
"     endif
"     setlocal winfixwidth
"     let t:netrw_lexbufnr = bufnr("%")
"   endif
" endfun
" " open project pane
" nnoremap <silent> <C-E> :call Lexplore('')<CR>
" vnoremap <silent> <C-E> :call Lexplore('')<CR>
" inoremap <silent> <C-E> :call Lexplore('')<CR>
"
" }}}

" Autocomplete {{{

if &history < 1000
  set history=1000            " more command history
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

Plugin 'Raimondi/delimitMate' " autocomplete brackets and quotes
let delimitMate_expand_cr = 1   " create closing brace on <cr>
let delimitMate_expand_space = 1
let delimitMate_excluded_ft = "mail,txt,ghmarkdown,markdown"  " exclude filetypes

set completeopt=longest,menuone " sort by longest, always display menu
set complete-=i                 " remove caseignored matches

" simulate a Down keypress to keep an item highlighted as you type
inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

" }}}

" CtrlP Options {{{

let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|\.git\/'
Plugin 'kien/ctrlp.vim' " plugin for Sublime Text-like CtrlP
nnoremap <leader><c-p> :CtrlPMRUFiles<cr>

" }}}

" Filetype: Hypr {{{

Plugin 'Glench/Vim-Jinja2-Syntax'
autocmd BufNewFile,BufReadPost *.hypr,*.hypr.live set filetype=jinja

" }}}

" Filetype: JavaScript {{{

Plugin 'jelera/vim-javascript-syntax' " syntax highlighting
Plugin 'pangloss/vim-javascript'      " indentation
Plugin 'Shutnik/jshint2.vim'          " JSHint command

function s:JsSetup()
  setlocal filetype=javascript
  colorscheme distinguished
  set background=dark
  set laststatus=2
  set cc=80
  hi IndentGuidesEven guibg=#222222
  hi IndentGuidesOdd guibg=#272727
  hi TabChars guifg=#990000 ctermfg=red
  match TabChars /\t/
  hi NonText guifg=#990000 ctermfg=red
  AirlineRefresh
endfunction

augroup javascript
  au!
  au BufRead,BufNewFile *.js,*.es6 call s:JsSetup()
augroup END

" }}}

" Filetype: JSON {{{

Plugin 'elzr/vim-json' " syntax highlighting

" }}}

" Filetype: Less {{{

Plugin 'groenewege/vim-less' " syntax highlighting

" }}}

" Filetype: Jade {{{

Plugin 'digitaltoad/vim-jade.git'
autocmd BufNewFile,BufReadPost *.jade set filetype=jade

" }}}

" Filetype: Markdown {{{

Plugin 'jtratner/vim-flavored-markdown' " syntax highlighting
Plugin 'suan/vim-instant-markdown'      " preview in realtime browser
let g:instant_markdown_autostart = 0    " don't launch a browser for each file!

" markdown mode requires this, see https://github.com/plasticboy/vim-markdown
let g:vim_markdown_folding_disabled=1

function s:MarkdownMode()
  setlocal filetype=ghmarkdown
  " colorscheme solarized
  set laststatus=2
  " set background=light
  AirlineRefresh
endfunction

augroup markdown
    au!
    au BufNewFile,BufRead *.mdown,*.md,*.markdown call s:MarkdownMode()
augroup END

" }}}

" Todo List {{{

Plugin 'zetlen/vim-simple-todo'
let g:simple_todo_tick_symbol = 'x'

" bind last search as foldmethod to hide and show certain tasks
nnoremap \] :setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2<CR>

" open todo list
command Todo :e ~/Dropbox/todo.mdown | /\[ \]/

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
colorscheme sorcerer
set laststatus=2
" }}}

" GUI Only Options {{{
" if has("gui_running")
"     set transparency=3
"     au GUIEnter * set fullscreen
" endif
" }}}

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
" vim:foldmethod=marker:foldlevel=0
