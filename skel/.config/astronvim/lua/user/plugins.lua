return {
	{
		"goolord/alpha-nvim",
		cmd = "Alpha",
		opts = function()
			local after_last_slash = function(path)
				return string.match(path, "[^/]+$")
			end

			local dashboard = require("alpha.themes.dashboard")
			local project_tag
			local git_dir = io.popen("git rev-parse --show-toplevel 2> /dev/null"):read("*line")
			if not git_dir then
				-- If it's not a git repository, just print the current directory name
				project_tag = vim.loop.cwd()
			else
				local git_remote_list = io.popen("git remote"):read("*a")
				if git_remote_list == "" then
					project_tag = after_last_slash(git_dir)
				else
					local git_remote = io.popen("git remote get-url origin"):read("*line")
					project_tag = after_last_slash(git_remote)
				end
			end
			local project_tag_font = "miniwi"
			local project_tag_formatted = {}
			local figlet_output = io.popen(string.format("figlet -W -f %s %s", project_tag_font, project_tag))
			for line in figlet_output:lines() do
				table.insert(project_tag_formatted, line)
			end
			dashboard.section.header.val = project_tag_formatted
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
		"kevinhui/vim-docker-tools",
		cmd = {
			"DockerToolsToggle",
			"DockerToolsOpen",
			"DockerToolsClose",
		},
		event = {
			"BufEnter docker-compose.yml",
			"BufEnter docker-compose.yaml",
		},
	},
}
