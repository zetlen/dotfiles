" Movement and keybindings. <leader> is set in 00-leader.vim.

nnoremap j gj
nnoremap k gk

" quickly kill quickfixes and loclists
noremap <leader>c :windo lcl\|ccl<cr>

" format text reasonably. see :help fo-table
set formatoptions=tcqlj
set lbr

" highlight last inserted text
nnoremap gV `[v`]

" Completion popup: <tab>/<s-tab> walk the menu and <cr> accepts the
" highlighted match, whatever opened it (LSP autotrigger in nvim, <c-x>
" completions anywhere). With no popup open all three keep their ordinary
" meanings -- summoning completion is a separate key (see z/completion.lua).
inoremap <expr> <tab>   pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <expr> <s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
inoremap <expr> <cr>    pumvisible() ? "\<c-y>" : "\<cr>"

set backspace=indent,eol,start " backspace can move over lines
set whichwrap+=<,>,h,l         " left and right can move over lines

set nrformats-=octal           " don't assume 0-leader numbers are octal

set timeout                    " no weird delay in bindings
set timeoutlen=100             " if weird delay is there, it's short
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

" get higroups under line
map <leader>h :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" make splits go down and right
set splitbelow
set splitright
