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
  -- surround/comment/git verbs, so muscle memory carries over intact.
  gh('joshdick/onedark.vim'),
  gh('tpope/vim-vinegar'),
  gh('tpope/vim-surround'),
  gh('tpope/vim-fugitive'),
  gh('tomtom/tcomment_vim'),
  gh('nathanaelkane/vim-indent-guides'),
  gh('imsnif/kdl.vim'),

  -- The IDE layer.
  gh('nvim-lua/plenary.nvim'),      -- codecompanion dependency
  gh('b0o/schemastore.nvim'),       -- JSON/YAML schemas from SchemaStore.org
  gh('olimorris/codecompanion.nvim'), -- ACP client
}, {
  -- Don't block a fresh headless box on an interactive install prompt.
  confirm = false,
})

-- Deliberately NOT installed here, unlike the plain vim plugin list:
--   * editorconfig-vim  -- neovim has editorconfig support built in
--   * vim-javascript-syntax, vim-js-indent, vim-jsx, typescript-vim
--       All are unmaintained (vim-jsx last shipped in 2016) and exist to patch
--       gaps that neovim's bundled runtime syntax plus LSP semantic tokens
--       already cover. Adding nvim-treesitter here is the natural next step if
--       the highlighting isn't good enough.

pcall(vim.cmd.colorscheme, 'onedark')
