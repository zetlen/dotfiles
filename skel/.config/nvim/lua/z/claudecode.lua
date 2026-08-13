-- Claude Code IDE integration: let the CLI see what the editor sees.
--
-- claudecode.nvim speaks the same WebSocket protocol as the official VS Code
-- extension. On startup it opens a server and writes a lock file under
-- ~/.claude/ide/, which makes this nvim discoverable to any `claude` on the
-- machine. Once attached, the CLI tracks the active buffer and live visual
-- selection, and edits it proposes open here as native diff views.
--
-- The claude TUI itself stays outside the editor: Herdr already owns
-- terminals and agent orchestration, so the plugin's embedded-terminal half
-- is switched off. Launch `claude --ide` in a Herdr pane -- or type /ide in
-- a session that is already running -- and pick this nvim instance.

require('claudecode').setup({
  terminal = { provider = 'none' },
})

-- "Hand this to Claude": the selection in visual mode, the whole file in
-- normal mode. Either arrives in the attached CLI as an @-mention.
vim.keymap.set('v', '<leader>a', '<cmd>ClaudeCodeSend<cr>', {
  desc = 'Send selection to Claude',
})
vim.keymap.set('n', '<leader>a', '<cmd>ClaudeCodeAdd %<cr>', {
  desc = 'Add file to Claude context',
})
