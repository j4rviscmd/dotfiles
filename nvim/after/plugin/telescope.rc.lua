local status, telescope = pcall(require, "telescope")
if not status then
	return end

local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local function telescope_buffer_dir()
	return vim.fn.expand("%:p:h")
end

local fb_actions = require("telescope").extensions.file_browser.actions

telescope.setup({
	defaults = {
		mappings = {
			n = {
				["q"] = actions.close,
			},
      i = {
       ['<C-[>'] = actions.close,
      }
		},
	},
	extensions = {
		file_browser = {
			theme = "dropdown",
			-- disables netrw and use telescope-file-browser in its place
			hijack_netrw = true,
			mappings = {
				["n"] = {
					-- your custom normal mode mappings
					["ma"] = fb_actions.create,
					["mc"] = fb_actions.copy,
					["mr"] = fb_actions.rename,
					["md"] = fb_actions.remove,
					["h"] = fb_actions.goto_parent_dir,
					["/"] = function()
						vim.cmd("startinsert")
					end,
					["<C-u>"] = function(prompt_bufnr)
						for i = 1, 10 do
							actions.move_selection_previous(prompt_bufnr)
						end
					end,
					["<C-d>"] = function(prompt_bufnr)
						for i = 1, 10 do
							actions.move_selection_next(prompt_bufnr)
						end
					end,
					["<PageUp>"] = actions.preview_scrolling_up,
					["<PageDown>"] = actions.preview_scrolling_down,
				},
			},
		},
	},
})


vim.keymap.set("n", "<C-i>", function()
	builtin.find_files({
		no_ignore = false,
		hidden = true,
		layout_config = { height = 40 },
	})
end)

vim.keymap.set("n", "<C-g>", function()
	-- Use ripgrep package
	builtin.live_grep({
		layout_config = { height = 40 },
  })
end)

vim.keymap.set("n", "\\\\", function()
	builtin.buffers()
end)

vim.keymap.set("n", ";t", function()
	builtin.help_tags()
end)

vim.keymap.set("n", ";;", function()
	builtin.resume()
end)

vim.keymap.set("n", ";e", function()
	builtin.diagnostics()
end)

telescope.load_extension("file_browser")
vim.keymap.set("n", "<C-o>", function()
	telescope.extensions.file_browser.file_browser({
		path = "%:p:h",
		cwd = telescope_buffer_dir(),
		respect_gitignore = false,
		hidden = true,
		grouped = true,
		previewer = true,
		initial_mode = "normal",
		layout_config = { height = 40 },
	})
end)
