-- -- 構文エラー時に行末でなく行直下にエラー内容を表示するプラグイン
-- local status, lsp_lines = pcall(require, "lsp_lines")
-- if not status then
-- 	return
-- end

-- lsp_lines.setup({
-- 	severity = vim.diagnostic.severity.WARN, -- only severity at or above this level will show
-- 	current_line_only = true, -- only show virtual lines on cursor line only
-- 	show_virt_line_events = { "CursorHold" }, -- events to show virtual lines
-- 	hide_virt_line_events = { "CursorMoved", "InsertEnter" }, -- events to hide virtual lines. CursorMoved is recommended only if current_line_only is true
-- 	diagnostics_filter = lsp_lines.most_severe_level_of_buffer, -- pick available diagnostic filters or write your own for this key, or omit this key to not use any filter
-- })

-- vim.diagnostic.config({
-- 	virtual_text = false,
-- })
