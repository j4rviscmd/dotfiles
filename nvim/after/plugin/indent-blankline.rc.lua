local status, ibl = pcall(require, "ibl")
if not status then
	return
end

local highlight = {
	"CursorColumn",
	"Whitespace",
}

ibl.setup({
	indent = { highlight = highlight, char = "" },
	whitespace = {
		highlight = highlight,
		remove_blankline_trail = false,
	},
	scope = { enabled = false },
})
