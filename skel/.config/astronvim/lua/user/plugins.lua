return {
	{
		"goolord/alpha-nvim",
		cmd = "Alpha",
		opts = function()
			local dashboard = require("alpha.themes.dashboard")
			local toiletfontdir = io.popen("figlet -I2"):read()
			local fontslist = io.popen(string.format('ls -1 "%1s"/*.flf', toiletfontdir)):lines()
			local fonts = {}
			for font in fontslist do
				table.insert(fonts, font)
			end
			math.randomseed(os.time())
			local pickedfont = fonts[math.random(1, #fonts)]
			local greeting = {}
			local greetingtext = io.popen(string.format("figlet -W -f %s hi", pickedfont))
			for line in greetingtext:lines() do
				table.insert(greeting, line)
			end
			dashboard.section.header.val = greeting
			dashboard.section.header.opts.hl = "DashboardHeader"

			local button = require("astronvim.utils").alpha_button
			dashboard.section.buttons.val = {
				button("LDR n", "  New File  "),
				button("LDR f f", "  Find File  "),
				button("LDR f o", "  Recents  "),
				button("LDR f w", "  Find Word  "),
				button("LDR f '", "  Bookmarks  "),
				button("LDR S l", "  Last Session  "),
			}

			dashboard.config.layout[1].val = vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) })
			dashboard.config.layout[3].val = 5
			dashboard.config.opts.noautocmd = true
			return dashboard
		end,
		config = require("plugins.configs.alpha"),
	},
	{
		"rcarriga/nvim-notify",
		init = function()
			require("astronvim.utils").load_plugin_with_func("nvim-notify", vim, "notify")
		end,
		opts = {
			stages = "fade_in_slide_out",
			render = "compact",
			on_open = function(win)
				vim.api.nvim_win_set_config(win, { zindex = 1000 })
			end,
		},
		config = require("plugins.configs.notify"),
	},
	{
		"kevinhui/vim-docker-tools"
	}
}
