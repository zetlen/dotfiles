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
      \   s:editor . ' %{mode(1)}'
      \ . ' »%='
      \ . '%m%h%r'
      \ . '  %F'
      \ . ' » '
      \ . '%l/%L:%c'
      \ . ' » %y'
