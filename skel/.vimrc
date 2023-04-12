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
set statusline+=:
set statusline+=%c
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

Plug 'imsnif/kdl.vim'

" }}}

" Spaces and Tabs {{{

set tabstop=2                            " visual spaces per tab
set shiftwidth=2                         " tab size of reindent > < operations
set expandtab                            " always spaces, everywhere, forever
set autoindent                           " guess smart indents
set smarttab                             " respond reasonably to tab key
Plug 'editorconfig/editorconfig-vim'   " Use editorconfig
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

" switch quickly between buffers
nnoremap <leader>; :b#<cr>
vnoremap <leader>; <esc>:b#<cr>
inoremap <leader>; <esc>:b#<cr>

" quickly kill quickfixes and loclists
noremap <leader>c :windo lcl\|ccl<cr>

" commenting code
Plug 'tomtom/tcomment_vim'

" surround commands (ysiw{ csa{[ things like that)
Plug 'tpope/vim-surround'

" quickly toggle relativenumber
nnoremap <leader>n :set relativenumber!<cr>
vnoremap <leader>n :set relativenumber!<cr>

" format text reasonably. see :help fo-table
set formatoptions=tcqlj
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

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

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

" enter paste mode with ,p
set pastetoggle=<leader>p

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

if executable('rg')

" Use ripgrep for searching ⚡️
" Options include:
" --vimgrep -> Needed to parse the rg response properly for ack.vim
" --type-not sql -> Avoid huge sql file dumps as it slows down the search
" --smart-case -> Search case insensitive if all lowercase pattern, Search
" case sensitively otherwise
	let g:ackprg = 'rg --vimgrep --type-not sql --smart-case'
elseif executable('ag')
" Use the-silver-searcher for searching
  let g:ackprg = 'ag --vimgrep'
endif

" Auto close the Quickfix list after pressing '<enter>' on a list item
let g:ack_autoclose = 1

" Any empty ack search will search for the work the cursor is on
let g:ack_use_cword_for_empty_search = 1

" Don't jump to first match
cnoreabbrev Ack Ack!

" Maps <leader>/ so we're ready to type the search keyword
nnoremap <Leader>/ :Ack!<Space>

" Navigate quickfix list with ease
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> ]q :cnext<CR>
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
set nowritebackup           " Seriously
set nowb                    " Don't write backup file
set noswapfile              " Boy are .swps annoying huh
Plug 'tpope/vim-fugitive' " git interactions

" mouse stuff
set mouse=a
set ttymouse=xterm2

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

Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
  \ coc#pum#visible() ? coc#pum#next(1) :
  \ CheckBackspace() ? "\<Tab>" :
  \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ?  coc#pum#confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
noremap <F2> <Plug>(coc-rename)
inoremap <F2> <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" }}}

" Filetype: JavaScript {{{

Plug 'jelera/vim-javascript-syntax' " syntax highlighting
Plug 'gavocanov/vim-js-indent'      " indentation
Plug 'mxw/vim-jsx'                  " JSX highlighting and indenting

function! s:JsSetup()
  set background=dark
  set cc=100
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

Plug 'leafgarland/typescript-vim' " syntax highlighting
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
  autocmd BufNewFile,BufRead .jshintrc setlocal filetype=jsonc
  " https://mochajs.org/#configuring-mocha-nodejs
  autocmd BufNewFile,BufRead .mocharc.json setlocal filetype=jsonc
  autocmd BufNewFile,BufRead .mocharc.jsonc setlocal filetype=jsonc
  " https://github.com/neoclide/coc.nvim
  autocmd BufNewFile,BufRead coc-settings.json setlocal filetype=jsonc
  " https://github.com/clutchski/coffeelint/pull/407
  autocmd BufNewFile,BufRead coffeelint.json setlocal filetype=jsonc
  " https://github.com/microsoft/TypeScript/pull/5450
  autocmd BufNewFile,BufRead tsconfig.json setlocal filetype=jsonc
  " https://github.com/Alexays/Waybar/wiki/Configuration
  autocmd BufNewFile,BufRead */waybar/config setlocal filetype=jsonc
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

" Load Local {{{
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
" }}}
" vim:foldmethod=marker:foldlevel=0
