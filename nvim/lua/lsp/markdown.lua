-- markdown言語のLinter/Formatter/LSP設定
-- NOTE: 保存時auto-fix(--fix)は行わない。README.md等の他開発者の記載を
-- 整形するリスクが高いため、診断表示のみとする
-- NOTE: markdownlintバイナリはmasonで手動インストール前提(mason-lspconfigの自動管理対象外)
return {
  -- LSPサーバー(marksman: 見出しジャンプ・リンク補完)
  lsp = { "marksman" },
  filetypes = { "markdown" },
  -- Why: prettierはconformの:Format実行に必須だが、lsp/init.luaのexecutables_by_ftは
  -- バッファオープン時のcli存在チェックに使われるため、ここに含めないと:Formatが
  -- 欠落に気づかず失敗する。warn文言の:MasonInstall prettierで導入導線を統一する
  -- (lsp/init.lua の BufEnter 存在チェック参照)
  executables = { "marksman", "markdownlint", "prettier" },
  -- nvim-lint: 診断表示のみ
  linters = {
    markdown = { "markdownlint" },
  },
  -- conform.nvim: :Format手動実行時のみ(保存時auto-formatはしない方針)
  formatters = {
    markdown = { "prettier" },
  },
}
