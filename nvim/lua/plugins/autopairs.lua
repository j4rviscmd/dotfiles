-- 括弧・クォート・HTMLタグの自動ペア入力
return {
  -- nvim-autopairs: ( [ { ' " ` の自動ペア入力
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({
        -- treesitterで文字列/コメント内のペア入力を抑制する
        check_ts = true,
        -- Note: fast_wrap(単語を括弧で囲む拡張)は無効。nilの場合無効になる
      })

      -- Why: JSX/TSX(Array<string>等のジェネリクス)と衝突するため、
      --   <> ペアはhtml系filetypeのみ有効化する
      local Rule = require("nvim-autopairs.rule")
      npairs.add_rule(Rule("<", ">", { "html", "xml", "vue", "svelte", "php", "astro", "eruby" }))

      -- Why: 関数補完を確定した際に()を自動付与するためnvim-cmpと連携する
      local cmp = require("cmp")
      cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
    end,
  },

  -- nvim-ts-autotag: treesitterでHTMLタグの閉じ・リネーム補完
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    -- Note: タグ閉じ(enable_close)・リネーム(enable_rename)はデフォルト有効。
    --   enable_close_on_slash(</入力時の自動閉じ)はデフォルト無効。必要なら opts で有効化
    opts = {},
  },
}
