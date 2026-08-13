-- JSON validation + completion against SchemaStore. This is what makes
-- package.json, tsconfig.json, and .github/workflows/* tell you that you got a
-- key wrong before you find out at runtime.
local ok, schemastore = pcall(require, 'schemastore')

return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  -- jsonc matters: the shared config maps tsconfig.json/.eslintrc.json to it.
  filetypes = { 'json', 'jsonc' },
  root_markers = { '.git' },
  settings = {
    json = {
      schemas = ok and schemastore.json.schemas() or nil,
      validate = { enable = true },
    },
  },
}
