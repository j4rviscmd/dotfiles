-- nvim-scp: scp によるリモートホストとのファイル/ディレクトリ転送
return {
  "j4rviscmd/nvim-scp",
  version = "*", -- follow the latest tag
  dependencies = { "nvim-telescope/telescope.nvim", "j-hui/fidget.nvim" },
  -- dir = "~/work/dev/nvim-scp/.worktrees/path-jump/", -- TODO: 動確後また削除
  cmd = { "ScpUpload", "ScpUploadCurrent", "ScpDownload" },
  opts = {
    -- Why: 転送先は自分のraspi(Pi5+Ubuntu)に固定(~/.ssh/config "Host raspi"、memory/raspi-pironman-display.md)
    -- Constraint: hostには~/.ssh/configのHost名を指定し、鍵認証のみ対応(パスワード認証不可) — プラグイン仕様(~/work/dev/nvim-scp/README.md)
    host = "raspi",
    remote_base_path = "~",
  },
  keys = {
    { "<leader>su", "<cmd>ScpUpload<cr>", desc = "SCP upload" },
    { "<leader>sc", "<cmd>ScpUploadCurrent<cr>", desc = "SCP upload current file" },
    { "<leader>sd", "<cmd>ScpDownload<cr>", desc = "SCP download" },
  },
}
