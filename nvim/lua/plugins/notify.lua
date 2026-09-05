-- TODO: 以下のユースケースを設定に反映する
-- 1. LSP進捗表示（Indexing, Formatting等）→ fidget.nvimで実現(plugins/fidget.lua)
-- 2. LSPエラー/警告通知
-- 3. プラグインからの通知（telescope, lazy.nvim, gitsigns等）
-- 4. マクロ/操作の完了通知（Yanked, Saved, Git pushed等）
-- 5. noice.nvimとの連携（コマンドライン/検索/メッセージのモダンUI化）

return {
  "rcarriga/nvim-notify",
  config = function()
    -- nvim-notifyの型定義でmerge_duplicatesが必須フィールド扱いになっているバグにより
    -- missing-fields診断を抑制。上流で修正されたら不要になる
    ---@diagnostic disable-next-line: missing-fields
    require("notify").setup({
      background_colour = "#000000",
      timeout = 1500,
    })
    vim.notify = require("notify")
  end,
}
