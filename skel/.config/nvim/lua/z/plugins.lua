-- Plugins, via vim.pack -- neovim 0.12's built-in manager. No lazy.nvim: this
-- set is small enough that a plugin manager would be more code than the
-- plugins it manages, and vim.pack needs no bootstrap step on a fresh box.
--
-- Versions are pinned in ~/.config/nvim/nvim-pack-lock.json (written at
-- runtime, not tracked in the dotfiles repo). Update with :Pack update.

local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add({
  -- Parity with plain vim: same colorscheme, same netrw tweaks, same
  -- surround/git verbs, so muscle memory carries over intact.
  gh('joshdick/onedark.vim'),
  gh('tpope/vim-vinegar'),
  gh('tpope/vim-surround'),
  gh('tpope/vim-fugitive'),

  -- The IDE layer.
  gh('b0o/schemastore.nvim'),       -- JSON/YAML schemas from SchemaStore.org
  gh('coder/claudecode.nvim'),      -- Claude Code IDE protocol (z/claudecode.lua)
  gh('folke/which-key.nvim'),       -- keymap popup on <leader> etc. (z/whichkey.lua)
  gh('MagicDuck/grug-far.nvim'),    -- live project search/replace panel (:GrugFar)
}, {
  -- Don't block a fresh headless box on an interactive install prompt.
  confirm = false,
})

-- Syntax, indent, editorconfig and gc commenting come from neovim's bundled
-- runtime. nvim-treesitter is the next step if that highlighting falls short.

pcall(vim.cmd.colorscheme, 'onedark')

-- Project-wide search/replace, prefilled with the word under the cursor.
vim.keymap.set('n', '<leader>sr', function()
  require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })
end, { desc = 'Search/replace in project' })
