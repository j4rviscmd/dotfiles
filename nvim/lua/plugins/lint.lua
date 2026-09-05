-- nvim-lint: linter実行による診断表示
-- 登録内容はlua/lsp/配下の言語モジュールから供給される
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = require("lsp").linters_by_ft

    -- markdownlint: MD013(行長80文字制限)は無効
    -- Why: 日本語Markdownは80文字で折り返すと逆に読みにくく、実害が薄いため
    local markdownlint = lint.linters.markdownlint
    -- Why: nvim-lintのlinter定義はテーブル直定義と遅延評価のファクトリ関数の両形態が
    -- 許容され、実行時は本体側で同様の分岐をしてから利用する(nvim-lint lua/lint.lua
    -- lookup_linter参照)。関数のままindexするとエラーになるため、ここでも同じ正規化をする
    if type(markdownlint) == "function" then
      markdownlint = markdownlint()
    end
    -- Note: argsは上書きだとデフォルト値とのマージではなく全置換になるため、stdin診断に
    -- 必須の--stdinを再指定している(欠くとmarkdownlintがファイル入力を待って診断0件に
    -- なる。ignore_exitcode=trueで黙って失敗する)
    -- 変更時注意: ファクトリ関数形態のlinterは都度新テーブルを返すため、このargs上書きは
    -- 現行のテーブル直定義(markdownlint.luaがテーブルをreturn)でのみ有効
    markdownlint.args = { "--stdin", "--disable", "MD013" }

    local group = vim.api.nvim_create_augroup("UserNvimLint", {})

    -- バッファ進入時・保存時・ノーマルモード復帰時・ノーマルモード編集時にlint実行
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
      group = group,
      callback = function()
        lint.try_lint()
      end,
    })

    -- 挿入モード中の入力毎もlint実行
    -- Why: nvim-lintにdebounce機能がないためtimerで手実装し、入力停止500ms後に
    -- 1回だけ実行する。キーストローク毎のプロセス起動を避けつつ逐次診断を実現するため
    local timer = assert(vim.uv.new_timer())
    vim.api.nvim_create_autocmd("TextChangedI", {
      group = group,
      callback = function()
        timer:stop()
        timer:start(
          500,
          0,
          vim.schedule_wrap(function()
            lint.try_lint()
          end)
        )
      end,
    })
  end,
}
