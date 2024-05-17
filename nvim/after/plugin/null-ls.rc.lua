local status, mason_null_ls = pcall(require, "mason-null-ls")
if not status then
	return
end

local status2, null_ls = pcall(require, "null-ls")
if not status2 then
	return
end

mason_null_ls.setup({
	ensure_installed = {
		"prettierd",
		"stylua",
		"ruff",
	},
	-- automatic_installation = true,
	handlers = {},
})

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- BufWritePre: ファイルを保存する前に発火します。
-- BufWritePost: ファイルを保存した後に発火します。
-- BufReadPre: ファイルを読み込む前に発火します。
-- BufReadPost: ファイルを読み込んだ後に発火します。
-- BufEnter: バッファに入る時に発火します。
-- BufLeave: バッファから出る時に発火します。
-- CursorMoved: カーソルが移動した時に発火します。
-- CursorMovedI: インサートモードでカーソルが移動した時に発火します。
-- FileType: ファイルのタイプが検出された時に発火します。
-- VimEnter: Neovimが起動した時に発火します。

null_ls.setup({
	sources = {
		null_ls.builtins.formatting.prettierd.with({
			disabled_filetypes = { "markdown" },
		}),
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.ruff,

		-- Ruby静的解析
		-- null_ls.builtins.diagnostics.rubocop,
		null_ls.builtins.diagnostics.ruff,
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ async = false })
					-- 保存後に再度構文エラーチェックプラグインをONにする
					vim.diagnostic.config({ virtual_lines = true })
				end,
			})
		end
	end,
	debug = true,
})
