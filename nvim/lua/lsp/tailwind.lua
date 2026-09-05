-- Tailwind CSS言語のLSP設定
-- tailwindcss-language-serverがclassname補完とhoverでの実際のCSSスタイル表示
-- (例: w-10 -> width: 2.5rem)を提供する
-- NOTE: 補完対象のclass属性(class/className等)とfiletypesはlspconfig既定値を使用
return {
  -- Note: LSPサーバー名は"tailwindcss"だが、masonパッケージ名・実バイナリ名は
  -- "tailwindcss-language-server"(~/.local/share/nvim/mason/packages/ 配下と同名)。
  -- executables_by_ftの存在チェックで案内される「:MasonInstall tailwindcss-language-server」は
  -- このパッケージ名に一致するため成立する
  lsp = { "tailwindcss" },
  linters = {},
  formatters = {},
  filetypes = { "html", "css", "typescriptreact", "javascriptreact" },
  executables = { "tailwindcss-language-server" },
}
