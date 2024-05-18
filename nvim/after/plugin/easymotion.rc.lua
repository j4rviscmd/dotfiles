local status, hop = pcall(require, "hop")
if not status then
	return
end

hop.setup()
vim.keymap.set("n", "f", "<CMD>HopWord<CR>")
