" Interoperation with the rest of the machine.

set hidden                  " allow hidden buffers with changes
set clipboard=unnamed,unnamedplus " y/d/p use the OS clipboard (* on macOS, + on Linux)
set autoread                " respond smoothly to file changes
" 'autoread' only reloads when something runs :checktime. These events cover
" switching buffers, returning to the terminal, and pausing for 'updatetime'.
" silent! because :checktime errors inside the command-line window.
augroup checktime
  au!
  autocmd BufEnter,FocusGained,CursorHold,CursorHoldI * silent! checktime
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
