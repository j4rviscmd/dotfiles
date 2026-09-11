-- markdownのブラウザライブプレビュー
-- NOTE: キーマップなし。:MarkdownPreviewToggle / :MarkdownPreview / :MarkdownPreviewStop で運用
return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  -- Why: README掲載のyarn install方式。初回install時はbuild関数実行前にautoloadが
  -- rtpへ載らずvim.fn["mkdp#util#install"]がE117で失敗するため、shellビルドとする
  build = "cd app && yarn install",
}
