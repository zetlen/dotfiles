" Hand-rolled statusline -- no airline, no lualine. Shared so the fat editor
" looks identical to plain vim.
"
" Built as one quoted assignment rather than a stack of `set statusline+=\ `
" lines: that form encodes a literal space as a TRAILING backslash-space, which
" any trailing-whitespace-stripping editor or pre-commit hook silently turns
" into a line-continuation and breaks. Here every space is inside quotes.

set laststatus=2

" The two editors are configured to feel identical, which makes them easy to
" confuse, so the leftmost glyph names the engine: nf-dev-vim or
" nf-linux-neovim (nerd font required). The one has() conditional in the
" shared config -- telling the engines apart is the entire point of it.
let s:editor = has('nvim') ? "\uf36f" : "\ue7c5"

let &statusline =
      \   '%2*' . s:editor . ' %{mode(1)}%1*'
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
