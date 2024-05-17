local keymap = vim.keymap

-- vim.keymap.set("n", "<C-n>", "<CMD>BufferLineCycleNext<CR>")

-- 画面サイズ変更
-- tmux likeなマッピング
--
-- 縦を拡張
keymap.set("n", "<C-w><C-j>", "<C-w>+6")
-- 縦を縮小
keymap.set("n", "<C-w><C-k>", "<C-w>-6")
-- 横を拡張
keymap.set("n", "<C-w><C-h>", "<C-w><6")
-- 横を縮小
keymap.set("n", "<C-w><C-l>", "<C-w>>6")

-- 誤操作のマッピング無効化
-- vim.api.nvim_del_keymap("n", "<C-w>w")
keymap.set("n", "<C-w>w", "")
keymap.set("n", "<C-w><C-w>", "")
