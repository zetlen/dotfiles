return {
	n = {
		["<leader>c"] = {
			function()
				local bufs = vim.fn.getbufinfo({ buflisted = true })
				require("astronvim.utils.buffer").close(0)
				if require("astronvim.utils").is_available("alpha-nvim") and not bufs[2] then
					require("alpha").start(true)
				end
			end,
			desc = "Close buffer",
		},
		["<leader>ff"] = {
			function()
				require("telescope.builtin").find_files({
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/**", "--glob", "!**/node_modules/**" },
				})
			end,
			desc = "Find file",
		},
	},
}
