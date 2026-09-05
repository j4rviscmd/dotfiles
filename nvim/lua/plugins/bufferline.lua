return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "<C-n>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<C-p>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
  },
  opts = {
    options = {
      mode = "buffers",
      always_show_bufferline = false,
      show_buffer_close_icons = false,
      show_close_icon = false,
      themable = true, -- カラースキームに自動連携
      -- quickfixバッファ([No Name])をタブ一覧に表示しない
      custom_filter = function(buf_number)
        return vim.bo[buf_number].buftype ~= "quickfix"
      end,
    },
  },
}
