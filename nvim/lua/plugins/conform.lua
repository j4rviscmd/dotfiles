-- conform.nvim: formatter実行の土台
-- 登録内容はlua/lsp/配下の言語モジュールから供給される
return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    formatters_by_ft = require("lsp").formatters_by_ft,
  },
  config = function(_, opts)
    local conform = require("conform")
    conform.setup(opts)

    -- 手動フォーマットコマンド(全言語共通)
    -- Why: 保存時auto-formatを意図的に行わない言語(markdown等)や任意タイミングでの
    -- 整形に備える。キーバインドは付けず、コマンド実行のみで発火する
    -- NOTE: conform未登録の言語はLSP format(ruff/biome等)へfallbackする
    vim.api.nvim_create_user_command("Format", function(args)
      local range = nil
      if args.range ~= 0 then
        -- Why: end桁に0を渡すと範囲末尾行の先頭までとなり、最終行が整形対象から
        -- 漏れるため、末尾行の行末までを範囲に含める(conform公式recipe準拠)
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, end_line:len() },
        }
      end
      conform.format({
        -- Why: Windows環境でasync実行はformatterジョブが完了せず整形が適用され
        -- ないため同期実行とする(手動コマンドなのでブロックは許容)
        async = false,
        lsp_format = "fallback",
        range = range,
      })
    end, { range = true, desc = "手動フォーマット(conform → LSP fallback)" })
  end,
}
