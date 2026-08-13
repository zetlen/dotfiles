-- ~/.config/nvim/init.lua -- the "fat" editor.
--
-- This is NOT a second copy of my preferences. Every keybinding, the
-- statusline, search behavior, and filetype detection are sourced verbatim
-- from ~/.dotfiles/lib/vim/common/, exactly as plain vim sources them, so
-- `vim` and `nvim` feel the same. What lives here is only the part plain vim
-- cannot do: LSP, completion, schema validation, and ACP agent integration.
--
-- Plain vim stays untouched and lightweight. Use it for quick edits; use nvim
-- when you want the IDE.

local dotfiles = vim.env.DOTFILE_PATH
if not dotfiles or dotfiles == '' then
  dotfiles = vim.fn.expand('~/.dotfiles')
end

-- Shared preferences first, so <leader> exists before anything builds mappings.
vim.cmd('source ' .. vim.fn.fnameescape(dotfiles .. '/lib/vim/common.vim'))

require('z.plugins')
require('z.lsp')
require('z.acp')
