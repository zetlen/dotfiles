" Shared editor configuration, sourced by BOTH plain vim (~/.vimrc) and the
" heavier neovim setup (~/.config/nvim/init.lua). This is the single source of
" truth for preferences: keybindings, statusline, search, filetype detection.
"
" Everything under lib/vim/common/ must be *portable legacy vimscript*:
"   - no vim9script -- neovim cannot parse it at all
"   - no `Plug` declarations -- the two editors use different plugin managers
"   - no options that exist in only one engine (t_*, ttymouse, pastetoggle,
"     guicursor). Those live in the editor-specific config instead.
" Guarding every other line with has('nvim') is what makes shared configs
" miserable to maintain, so the split is by file, not by conditional.

let s:dotfiles = !empty($DOTFILE_PATH) ? $DOTFILE_PATH : expand('~/.dotfiles')

for s:fragment in sort(glob(s:dotfiles . '/lib/vim/common/*.vim', 0, 1))
  execute 'source' fnameescape(s:fragment)
endfor

unlet! s:dotfiles s:fragment
