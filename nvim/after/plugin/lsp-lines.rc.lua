-- 構文エラー時に行末でなく行直下にエラー内容を表示するプラグイン
local status, lsp_lines = pcall(require, "lsp_lines")
if not status then
	return
end

lsp_lines.setup({})

vim.diagnostic.config({
	virtual_text = false,
})
