" Hand-rolled statusline -- no airline, no lualine. Shared so the fat editor
" looks identical to plain vim.
"
" Built as one quoted assignment rather than a stack of `set statusline+=\ `
" lines: that form encodes a literal space as a TRAILING backslash-space, which
" any trailing-whitespace-stripping editor or pre-commit hook silently turns
" into a line-continuation and breaks. Here every space is inside quotes.

set laststatus=2

let &statusline =
      \   '%2*%{mode(1)}%1*'
      \ . ' »%='
      \ . '%m%h%r'
      \ . ' %3*%1*'
      \ . ' %4*%F'
      \ . ' » '
      \ . '%5*%l/%L:%c'
      \ . '%1* » %y'
" No `|` before the filetype, deliberately. The old vimrc asked for one with
" `set statusline+=|`, but `|` terminates a :set command so it never appeared;
" having now seen it rendered, it isn't wanted. Add it back as '» |%y' if that
" ever changes -- inside a quoted string the `|` is literal.

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
