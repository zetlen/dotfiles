-- typescript-language-server is only the LSP front end. The analysis is done
-- by tsserver.js from a `typescript` package, which the server looks for in
-- the project's node_modules and nowhere useful beyond that: no project
-- typescript, no server. Rather than have mise install a global typescript
-- that would drift from every project, a missing one is fetched on demand
-- with `npx -y` into npm's cache and the server is pointed at it. The fetch
-- runs async in root_dir(), so the first open in such a project pays a
-- notify-and-wait, never a frozen editor.
--
-- Pinned to typescript@6, the last JS-based line. TypeScript 7 is the native
-- (Go) compiler and ships no tsserver.js, so it cannot back this server at
-- all; a project on 7 needs `tsgo --lsp` instead, which is not wired up here.

local root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' }

local function project_tsserver(root)
  -- The same lookup the server itself does. If this hits, leave it alone.
  local path = root .. '/node_modules/typescript/lib/tsserver.js'
  return vim.uv.fs_stat(path) and path or nil
end

local fetched -- npx-fetched tsserver.js, memoised for the session
local waiting -- callbacks queued behind an in-flight fetch

local function fetch_tsserver(on_done)
  if fetched then
    return on_done(fetched)
  end
  if waiting then
    -- Opening several files at once must not spawn several npx runs.
    return table.insert(waiting, on_done)
  end
  waiting = { on_done }
  vim.notify('ts_ls: no typescript in this project; fetching one with npx -y', vim.log.levels.INFO)
  -- npx won't say where it unpacked the package, but it does put `tsc` on
  -- PATH, and that symlink sits two steps from tsserver.js.
  vim.system(
    { 'npx', '-y', '-p', 'typescript@6', 'sh', '-c', 'command -v tsc' },
    { text = true },
    function(res)
      local tsc = res.code == 0 and vim.trim(res.stdout) or ''
      local path = tsc ~= ''
        and vim.fs.normalize(vim.fs.dirname(tsc) .. '/../typescript/lib/tsserver.js')
      if path and vim.uv.fs_stat(path) then
        fetched = path
      end
      vim.schedule(function()
        if not fetched then
          vim.notify(
            'ts_ls: npx could not fetch typescript, not starting. '
              .. vim.trim(res.stderr or ''),
            vim.log.levels.WARN
          )
        end
        local callbacks = waiting
        waiting = nil
        for _, cb in ipairs(callbacks) do
          cb(fetched)
        end
      end)
    end
  )
end

return {
  -- The server itself comes from mise (lib/vim/30-editor.toml); on a box that
  -- skipped the editors step, npx serves that too.
  cmd = vim.fn.executable('typescript-language-server') == 1
      and { 'typescript-language-server', '--stdio' }
    or { 'npx', '-y', 'typescript-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = root_markers,
  -- Decide the root as root_markers would, then make sure a tsserver exists
  -- before letting the server start; on_dir is only called once it does.
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, root_markers)
    if not root or project_tsserver(root) then
      return on_dir(root)
    end
    fetch_tsserver(function(path)
      if path then
        on_dir(root)
      end
    end)
  end,
  -- params.initializationOptions is already a copy of init_options by the
  -- time this runs, so the path has to go onto the params themselves.
  before_init = function(params, config)
    if config.root_dir and project_tsserver(config.root_dir) then
      return
    end
    params.initializationOptions = vim.tbl_deep_extend(
      'force',
      params.initializationOptions or {},
      { tsserver = { path = fetched } }
    )
  end,
}
