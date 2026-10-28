-- ~/.config/nvim/init.lua -- the "fat" editor.
--
-- This is NOT a second copy of my preferences. Every keybinding, the
-- statusline, search behavior, and filetype detection are sourced verbatim
-- from ~/.dotfiles/lib/vim/common/, exactly as plain vim sources them, so
-- `vim` and `nvim` feel the same. What lives here is only the part plain vim
-- cannot do: LSP, completion, schema validation, and Claude Code IDE
-- integration.
--
-- Plain vim stays untouched and lightweight. Use it for quick edits; use nvim
-- when you want the IDE.

local dotfiles = vim.env.DOTFILE_PATH
if not dotfiles or dotfiles == '' then
  dotfiles = vim.fn.expand('~/.dotfiles')
end

-- Shared preferences first, so <leader> exists before anything builds mappings.
vim.cmd('source ' .. vim.fn.fnameescape(dotfiles .. '/lib/vim/common.vim'))

-- vim and nvim share one swap directory so that opening a file the other
-- editor has open raises the swapfile prompt. nvim's default SwapExists
-- handler answers that prompt itself whenever the swapfile's owner is a live
-- process of the same user, so it must go for the prompt to appear. The group
-- is absent on nvim versions that predate the handler.
pcall(vim.api.nvim_del_augroup_by_name, 'nvim.swapfile')

-- The IDE layer needs 0.12 (vim.pack) and 0.11 (native vim.lsp.config). This
-- config is symlinked onto every machine, but the neovim that mise builds is
-- opt-in, so an older distro nvim can end up reading it. Keep the shared
-- preferences -- they work anywhere -- and say why the rest is missing instead
-- of throwing on every startup.
if vim.fn.has('nvim-0.12') == 0 then
  vim.schedule(function()
    vim.notify(
      'nvim 0.12+ required for LSP/Claude; loaded shared config only. '
        .. 'Run the editors step of install_dotfiles.sh to get a current build.',
      vim.log.levels.WARN
    )
  end)
  return
end

require('z.plugins')
require('z.whichkey')
require('z.lsp')
require('z.completion')
require('z.claudecode')
