-- LSPのUIプラグイン
-- 実装/定義/呼出先へジャンプできる
local status, saga = pcall(require, "lspsaga")
if not status then
	return
end

saga.setup({
	finder = {
		max_height = 0.6,
		left_width = 0.3,
		right_width = 0.6,
		default = "def+imp+ref",
		layout = "float", -- normal or float
		silent = false,
		keys = {
			quit = { "q", "<Esc>", "<C-[>" },
			-- tabnew = "<CR>",
			tabe = "<CR>",
		},
	},
	lightbulb = {
		enable = false,
		sign = true,
		virtual_text = false,
	},
	symbol_in_winbar = {
		enable = false,
	},
	beacon = {
		enable = true,
		frequency = 7,
		border = "single",
		devicon = true,
		title = false,
	},
	-- server_filetype_map = {
	-- 	typescript = "typescript",
	-- },
	-- server_filetype_map = {metals = {'sbt', 'scala'}},
})

local opts = { noremap = true, silent = true }

-- vim.keymap.set('n', '<C-j>', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
vim.keymap.set("n", "<leader>h", "<Cmd>Lspsaga hover_doc<CR>", opts)
vim.keymap.set("n", "<leader>e", "<Cmd>Lspsaga show_cursor_diagnostics<CR>", opts)

local cursorRow = -1
local cursorColumn = -1
local file = ""

local function gotoCalleeAndCaller()
	-- カーソル位置の取得
	local beforeRow, beforeColumn = unpack(vim.api.nvim_win_get_cursor(0))
	cursorRow = beforeRow
	cursorColumn = beforeColumn
	file = vim.api.nvim_buf_get_name(0)
	-- 定義へのジャンプ試行
	vim.api.nvim_command("Lspsaga goto_definition")

	-- 非同期コマンドの実行が完了するまで待機
	vim.wait(100, function()
		local afterRow, _ = unpack(vim.api.nvim_win_get_cursor(0))
		return afterRow ~= beforeRow
	end, 10)

	-- カーソル位置の再取得
	local afterRow, _ = unpack(vim.api.nvim_win_get_cursor(0))

	-- 定義ジャンプの成功/失敗の判定と参照検索の実行
	if beforeRow == afterRow then
		vim.api.nvim_command("Lspsaga finder ref")
	else
		return
	end
end

-- ジャンプ先からの戻り
-- 開くファイルと行数および列数の復元
local function gotoBackHistory()
	if cursorRow == -1 then
		return
	end
	vim.api.nvim_command("edit " .. file)
	vim.api.nvim_win_set_cursor(0, { cursorRow, cursorColumn })
end

vim.keymap.set("n", "<Space>d", gotoCalleeAndCaller, opts)
vim.keymap.set("n", "<Space>b", gotoBackHistory, opts)
