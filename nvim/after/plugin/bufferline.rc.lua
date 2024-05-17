local status, bufferline = pcall(require, "bufferline")
if not status then
	return
end

bufferline.setup({
	options = {
		mode = "buffers",
		separator_style = "slant",
		always_show_bufferline = false,
		show_buffer_close_icons = false,
		show_close_icon = false,
		color_icons = true,
    -- close_command = require('bufdelete').bufdelete,
	},
	highlights = {
		separator = {
			guifg = "#073642",
			guibg = "#002b36",
		},
		separator_selected = {
			guifg = "#073642",
		},
		background = {
			guifg = "#657b83",
			guibg = "#002b36",
		},
		buffer_selected = {
			guifg = "#fdf6e3",
			gui = "bold",
      underline = true,
		},
		fill = {
			guibg = "#073642",
		},
	},
})

vim.keymap.set("n", "<C-n>", "<CMD>BufferLineCycleNext<CR>")
vim.keymap.set("n", "<C-p>", "<CMD>BufferLineCyclePrev<CR>")

