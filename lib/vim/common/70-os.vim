" Interoperation with the rest of the machine.

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
" Backups hold the file as it was before the latest save. Swap files hold
" unsaved edits for crash recovery. Both live under one state directory so they
" never appear next to the edited file. The trailing // makes vim encode the
" full path into the file name, so same-named files from different directories
" do not overwrite each other. "." is left out of 'backupdir' and 'directory'
" on purpose: vim falls back to the next entry when the first cannot be used,
" and that fallback would put the file beside the edited one.
let s:state = expand('~/.local/state/vim')
silent! call mkdir(s:state . '/backup', 'p', 0700)
silent! call mkdir(s:state . '/swap', 'p', 0700)
let &backupdir = s:state . '/backup//'
let &directory = s:state . '/swap//'
unlet s:state
set backup
set writebackup
set swapfile

set mouse=a
