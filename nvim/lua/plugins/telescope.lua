-- telescope.nvim: ファジーファインダー（検索専用）
-- ビルドツール(make)がない環境（Windows等）ではfzf-native（Cビルド必須）をスキップ
local has_make = vim.fn.executable("make") == 1

return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    has_make and { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } or nil,
  },
  keys = {
    {
      "<C-i>",
      function()
        require("telescope.quick_open").quick_open()
      end,
      desc = "Quick Open (files / >commands)",
    },
    {
      "<C-g>",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Live grep",
    },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({})
    if has_make then
      telescope.load_extension("fzf")
    end
  end,
}

-- TODO:
-- 1. LSP 通知の表示
--
-- - 言語サーバーの起動/停止状態
-- - コード診断結果（エラー、警告）
-- - フォーマット完了通知
-- - コードアクションの実行結果
--
-- 2. プラグインマネージャーの通知
--
-- - lazy.nvim や packer.nvim からの更新通知
-- - プラグインのインストール/アップデート進捗
-- - 同期完了のお知らせ
--
-- 3. Git 操作の通知
--
-- - gitsigns.nvim との連携（hunk のステージング等）
-- - コミット、プッシュ、プルの結果表示
-- - ブランチ切り替え通知
--
-- 4. ファイル操作の通知
--
-- - ファイル保存完了
-- - 自動保存の実行通知
-- - 外部変更の検出アラート
--
-- 5. マクロ/レコーディング通知
--
-- - マクロ記録の開始/終了
-- - 検索/置換の結果件数表示
-- - ヤンク（コピー）した行数の表示
--
-- ---
-- 補足: telescope.nvim、noice.nvim、lualine.nvim などと組み合わせて使うことで、より統一感のある通知体験を実現できます。
