-- ACP: talk to Claude Code from inside the editor.
--
-- The Agent Client Protocol is to agents what LSP is to language servers -- it
-- decouples the agent from the editor. codecompanion is the client here; the
-- agent is the real Claude Code CLI, bridged by `claude-agent-acp` (installed
-- via mise, see lib/vim/30-editor.toml).
--
-- Because it drives the actual CLI rather than the raw API, it inherits the
-- auth, MCP servers, skills, and subagents already configured for `claude` on
-- this machine. Nothing to configure twice. If the CLI isn't logged in, run
-- `claude setup-token` (or export CLAUDE_CODE_OAUTH_TOKEN).

require('codecompanion').setup({
  interactions = {
    chat = {
      adapter = {
        name = 'claude_code',
        -- model = 'opus',  -- omit to use whatever the CLI defaults to
      },
    },
  },
})

vim.keymap.set({ 'n', 'v' }, '<leader>a', '<cmd>CodeCompanionChat Toggle<cr>', {
  desc = 'Toggle Claude chat',
})
vim.keymap.set({ 'n', 'v' }, '<leader>A', '<cmd>CodeCompanionActions<cr>', {
  desc = 'Claude action palette',
})
