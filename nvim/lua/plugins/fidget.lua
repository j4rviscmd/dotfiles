-- LSP進捗表示
-- rust_analyzerのindexing等$/progressを右下ウィンドウに集約表示する
-- (nvim-notifyで表示するとtoken毎に通知が積もるため専用pluginを使う)
return {
  "j-hui/fidget.nvim",
  event = "LspAttach",
  -- Why: nvim-notify(plugins/notify.lua)と併用するためoptsは既定のままにする
  -- fidgetの既定はvim.notifyを上書きせず(override_vim_notify = false)、
  -- on_open付き通知のみnvim-notifyへ委譲する(notification.redirectの既定)
  -- (fidget.nvim commit 6f793b2, lua/fidget/notification.lua)
  opts = {},
}
