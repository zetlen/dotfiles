-- LSP, using neovim 0.11+'s native API. No nvim-lspconfig, no Mason.
--
-- Each server is defined in its own file under ~/.config/nvim/lsp/<name>.lua
-- (neovim picks those up off the runtimepath automatically), which keeps the
-- editor config as modular as the rest of these dotfiles. mise owns the server
-- binaries -- see skel/.config/mise/conf.d/30-editor.toml -- so there is no
-- in-editor installer to keep in sync with the system.

vim.lsp.enable({
  'lua_ls',
  'ts_ls',
  'jsonls',
  'yamlls',
  'gopls',
  'ruff',
})

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2 },
  float = { border = 'rounded', source = true },
})

-- Completion without a completion engine: neovim's built-in LSP completion
-- with autotrigger. Keeps the popup on stock <c-n>/<c-p>/<c-y> ins-completion
-- keys instead of teaching my fingers a plugin's bindings, and it has no
-- compiled dependency to fail on a headless box. Swap in blink.cmp here if the
-- fuzzy matching ever isn't enough.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('z_lsp_attach', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
        autotrigger = true,
      })
    end
  end,
})

-- neovim 0.11 already ships the LSP keymaps I'd otherwise write by hand:
--   K hover, grn rename, gra code action, grr references, gri implementation,
--   gO document symbols, [d / ]d diagnostics, <c-s> signature help (insert).
-- Only the gaps get bindings, in the same <leader> style as the shared config.
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, {
  desc = 'Show diagnostic under cursor',
})
vim.keymap.set('n', '<leader>f', function()
  vim.lsp.buf.format({ async = true })
end, { desc = 'Format buffer via LSP' })
