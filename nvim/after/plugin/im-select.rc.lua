local status, im_select = pcall(require, "im_select")
if not status then
	return
end

local os = vim.loop.os_uname().sysname

if os == "Darwin" then
	im_select.setup({
		default_im_select = "com.apple.keylayout.ABC",
		set_previous_events = {},
	})
elseif os == "Windows_NT" then
	-- English: 0
	-- Japanese: 1
	im_select.setup({
		default_im_select = "0",
		default_command = "zenhan",
		set_previous_events = {},
	})
elseif os == "Linux" then
	print("Linux does not implement im-select.")
	return
else
	return
end
