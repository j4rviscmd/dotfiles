-- hop.nvim: 画面内の単語に即ジャンプ
return {
  "smoka7/hop.nvim",
  version = "*",
  keys = {
    { "f", "<cmd>HopWord<cr>", mode = { "n", "x", "o" }, desc = "Hop to word" },
  },
  opts = {
    keys = "etovxqpdygfblzhckisuran",
  },
}
