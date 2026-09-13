-- markdownのブラウザライブプレビュー
-- NOTE: キーマップなし。:MarkdownPreviewToggle / :MarkdownPreview / :MarkdownPreviewStop で運用
return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  -- Why: README掲載(Packer例)のnpm install方式。初回install時はbuild関数実行前にautoloadが
  -- rtpへ載らずvim.fn["mkdp#util#install"]がE117で失敗するため、shellビルドとする
  -- NOTE: upstreamはyarn.lockのみ追跡。初回buildはsemverレンジから解決され、2回目以降は生成済みpackage-lock.json基準で解決する
  -- Why: npm v7+は既存yarn.lockをregistry.npmjs.org形式へ書き換えるため、放置するとlazyが
  -- local changes検知してclean/updateに失敗する。build後にgit checkoutで復元する
  build = "cd app && npm install && git checkout -- yarn.lock",
}
