local ok, schemastore = pcall(require, 'schemastore')

return {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
  root_markers = { '.git' },
  settings = {
    yaml = {
      -- schemastore.nvim supplies the catalog, so the server's own
      -- (duplicate, network-fetching) store stays off.
      schemaStore = { enable = false, url = '' },
      schemas = ok and schemastore.yaml.schemas() or nil,
      validate = true,
    },
  },
}
