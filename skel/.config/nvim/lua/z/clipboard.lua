-- Over SSH, yanks reach the local machine's clipboard through OSC 52, the
-- terminal escape sequence for writing the clipboard. neovim only picks OSC 52
-- by itself when 'clipboard' is empty, and lib/vim/common/70-os.vim sets it,
-- so it is chosen here.
--
-- Both registers send to the clipboard ("c"). 'clipboard' includes unnamed,
-- so yanks land in "*", which neovim's stock OSC 52 provider would send to
-- the X primary selection instead.
--
-- Paste never queries the terminal. That query waits up to 10s on a terminal
-- that does not answer, and with 'clipboard' set it would run on every `p`.
-- It returns the last yank instead; text copied on the local machine comes in
-- through the terminal's own paste key.
if not vim.env.SSH_TTY then
  return
end

local send = require('vim.ui.clipboard.osc52').copy('+')
local last = { {}, 'v' }

local function copy(lines, regtype)
  last = { lines, regtype }
  send(lines)
end

local function paste()
  return last
end

vim.g.clipboard = {
  name = 'OSC 52, copy only',
  copy = { ['+'] = copy, ['*'] = copy },
  paste = { ['+'] = paste, ['*'] = paste },
}
