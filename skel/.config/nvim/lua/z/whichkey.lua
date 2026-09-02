-- which-key: press <leader> (or any other prefix) and pause, and a popup
-- lists what can follow. The catalogue is built from the keymaps' own `desc`
-- fields, so anything mapped with vim.keymap.set(..., { desc = ... }) shows
-- up labelled for free. The plugin hooks the prefix keys itself rather than
-- relying on 'timeoutlen', so the 100ms timeout in lib/vim/common/50-keys.vim
-- stays as it is; only the popup's own `delay` below decides when it appears.

local wk = require('which-key')

wk.setup({
  -- Long enough that a fluent <leader>; never flashes the popup, short
  -- enough that hesitating gets help.
  delay = 300,
  -- No mini.icons or devicons here; which-key's own glyph table still needs
  -- the Nerd Font that the statusline already assumes.
  icons = { mappings = true },
})

-- The shared vimscript mappings predate `desc` and plain vim ignores it, so
-- label them here instead of touching lib/vim/common/. An entry with no rhs
-- creates no keymap; it only names the one that already exists.
wk.add({
  { '<leader>;', desc = 'Alternate buffer', mode = { 'n', 'v' } },
  { '<leader>c', desc = 'Close quickfix and loclists', mode = { 'n', 'v' } },
  { '<leader>n', desc = 'Toggle relativenumber', mode = { 'n', 'v' } },
  { '<leader>h', desc = 'Highlight groups under cursor', mode = { 'n', 'v' } },
  { '<leader><space>', desc = 'Clear search highlight' },

  -- Plugin prefixes that otherwise show up as bare keys. tcomment's
  -- <leader>_ family mirrors its <c-_> maps (:help tcomment-maps).
  { '<leader>_', group = 'comment', mode = { 'n', 'v' } },
  { '<leader>__', desc = 'Toggle comment', mode = { 'n', 'v' } },
  { '<leader>_<space>', desc = 'Comment, prompting for delimiters', mode = { 'n', 'v' } },
  { '<leader>_b', desc = 'Block comment', mode = { 'n', 'v' } },
  { '<leader>_r', desc = 'Comment to end of line', mode = { 'n', 'v' } },
  { '<leader>_p', desc = 'Comment paragraph', mode = { 'n', 'v' } },
  { '<leader>_i', desc = 'Inline comment', mode = 'v' },
  { '<leader>_a', desc = 'Comment as filetype...', mode = { 'n', 'v' } },
  { '<leader>_n', desc = 'Comment as filetype, with count...', mode = { 'n', 'v' } },
  { '<leader>_s', desc = 'Comment as filetype subtype...', mode = { 'n', 'v' } },
  { '<leader>i', group = 'indent' },
  { '<leader>ig', desc = 'Toggle indent guides' },
})

-- Everything bound to this buffer alone (LSP attaches, filetype plugins).
vim.keymap.set('n', '<leader>?', function()
  wk.show({ global = false })
end, { desc = 'Buffer-local keymaps' })
