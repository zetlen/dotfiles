-- Completion without a completion engine: neovim's built-in LSP completion
-- with autotrigger. The popup keys are the stock ins-completion ones plus the
-- <tab>/<cr> pum mappings shared with plain vim (lib/vim/common/50-keys.vim),
-- and there is no compiled dependency to fail on a headless box. Swap in
-- blink.cmp here if the fuzzy matching ever isn't enough.

-- Without noinsert, the autotrigger writes the first match into the buffer as
-- you type and any stray keystroke keeps it. noinsert leaves the first item
-- merely highlighted -- <cr> accepts it, typing on filters it -- so nothing
-- lands in the buffer unasked. menuone keeps the menu up even for a single
-- match, which the <c-space> prober below relies on for visible feedback.
vim.o.completeopt = 'menuone,noinsert,fuzzy,popup'

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('z_completion', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
        autotrigger = true,
      })
    end
  end,
})

-- <c-space> summons completion by hand and, unlike the autotrigger, always
-- answers: no client, a server error, an empty result, or the menu. The
-- servers are asked directly instead of peeking at pumvisible() after a
-- delay, so "nothing here" is a definite answer rather than a guess about a
-- slow server.
vim.keymap.set('i', '<C-Space>', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/completion' })
  if #clients == 0 then
    vim.notify('No completions: no LSP client attached here offers them', vim.log.levels.WARN)
    return
  end
  local names = table.concat(
    vim.tbl_map(function(c) return c.name end, clients),
    ', '
  )
  vim.lsp.buf_request_all(bufnr, 'textDocument/completion', function(client)
    return vim.lsp.util.make_position_params(0, client.offset_encoding)
  end, function(results)
    local count, errors = 0, {}
    for client_id, res in pairs(results) do
      if res.err then
        local who = vim.lsp.get_client_by_id(client_id)
        table.insert(errors, (who and who.name or client_id) .. ': ' .. res.err.message)
      elseif res.result then
        -- CompletionList has .items; bare CompletionItem[] is also legal
        count = count + #(res.result.items or res.result)
      end
    end
    if #errors > 0 then
      vim.notify('Completion errors -- ' .. table.concat(errors, '; '), vim.log.levels.WARN)
    end
    if count == 0 then
      if #errors == 0 then
        vim.notify('No completions here (asked ' .. names .. ')', vim.log.levels.INFO)
      end
    elseif vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' then
      vim.lsp.completion.get()
    end
  end)
end, { desc = 'Summon LSP completion, or say why there is none' })
