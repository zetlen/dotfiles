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
set nobackup                " Backup is what Time Machine is for
set nowritebackup           " Seriously
set nowb                    " Don't write backup file
set noswapfile              " Boy are .swps annoying huh

set mouse=a
