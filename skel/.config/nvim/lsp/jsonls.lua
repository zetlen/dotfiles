-- JSON validation + completion against SchemaStore. This is what makes
-- package.json, tsconfig.json, and .github/workflows/* tell you that you got a
-- key wrong before you find out at runtime.
local ok, schemastore = pcall(require, 'schemastore')

return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  -- jsonc matters: neovim detects tsconfig.json and other JSON-with-comments
  -- files as jsonc.
  filetypes = { 'json', 'jsonc' },
  root_markers = { '.git' },
  settings = {
    json = {
      schemas = ok and schemastore.json.schemas() or nil,
      validate = { enable = true },
    },
  },
}
