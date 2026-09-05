-- rust言語のLinter/Formatter/LSP設定
-- rust_analyzer: 補完・診断・定義ジャンプ + rustfmt(format) + clippy(lint)
-- NOTE: rust-analyzer/clippy/rustfmtはrustup管理(mason管理外。mason = false)
return {
  lsp = { "rust_analyzer" },
  -- Why: rust_analyzerはrustup管理のためmasonのensure_installedから除外する
  -- (masonに入れるとMason版バイナリがPATHの先頭に置かれrustup版をshadowする)
  mason = false,
  filetypes = { "rust" },
  -- NOTE: rustup管理のためinstall指定でwarn時の案内をrustupコマンドにする
  executables = {
    { cmd = "rust-analyzer", install = "rustup component add rust-analyzer" },
    -- Why: cargoはrustupのcomponentではなくtoolchain同梱のため
    -- `rustup component add cargo`というcomponent追加が存在しない
    -- (`rustup component list`にcargo componentは無い)
    { cmd = "cargo", install = "rustup" },
  },
  -- Note: clippyの診断は本ファイルの check = { command = "clippy" } がLSP経由で出し、
  -- 整形もBufWritePreのLSP formatで担うため、nvim-lint/conformへは登録しない
  -- (nvim-lintにclippy、conformにrustfmtを足すと二重診断・二重整形になる)
  linters = {},
  formatters = {},
  --- サーバー固有のsettings(vim.lsp.config経由でサーバーへ渡される)
  lsp_settings = {
    rust_analyzer = {
      ["rust-analyzer"] = {
        cargo = { buildScripts = { enable = true } },
        procMacro = { enable = true },
        -- 保存時チェックをclippyにする(型・借用エラー + idiom警告)
        check = { command = "clippy" },
      },
    },
  },
  --- require("lsp")の初回ロード時に呼ばれる(autocmd登録等)
  --- @return nil
  on_setup = function()
    -- 保存時のrustfmt自動フォーマット(rust_analyzer経由)
    -- Why: rustfmtは事実上の標準スタイルでチーム差異小のため、プロジェクト設定の
    -- 有無に関わらず常時実行する(python/TSとは方針が異なる点に注意)
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("UserRustfmt", {}),
      pattern = "*.rs",
      callback = function(args)
        -- Why: rustfmtは.gitignoreを解釈しないため、prettierと同等の
        -- gitignore保護をnvim側で行う(lsp/init.luaのis_git_ignored参照)
        if require("lsp").is_git_ignored(args.buf) then
          return
        end
        -- Why: async = falseでないと書き込みが先行し、整形前の内容が保存される
        vim.lsp.buf.format({
          bufnr = args.buf,
          async = false,
          filter = function(client)
            return client.name == "rust_analyzer"
          end,
        })
      end,
    })
  end,
}
