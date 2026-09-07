-- telescope.nvim: ファジーファインダー（検索専用）
-- ビルドツール(make)がない環境（Windows等）ではfzf-native（Cビルド必須）をスキップ
local has_make = vim.fn.executable("make") == 1

return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    has_make and { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } or nil,
  },
  keys = {
    {
      "<C-i>",
      function()
        require("telescope.quick_open").quick_open()
      end,
      desc = "Quick Open (files / >commands)",
    },
    {
      "<C-g>",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Live grep",
    },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({})
    if has_make then
      telescope.load_extension("fzf")
    end
  end,
}
