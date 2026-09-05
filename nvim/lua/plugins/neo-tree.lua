-- neo-tree.nvim: ファイルエクスプローラー
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<C-o>", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      -- Why: トグル時の再帰的全展開をやめて follow_current_file 追従へ変更。
      -- leave_dirs_open=true で展開済みディレクトリを維持する(73837c7)
      follow_current_file = {
        enabled = true,
        leave_dirs_open = true,
      },
      use_libuv_file_watcher = true,
    },
    window = {
      width = 30,
      mappings = {
        -- Note: m は 79de655 で noop 無効化していたが、m-prefix キー一覧の
        -- 凡例ポップアップに転用した(m は単独では動作しないプレフィックス)
        ["m"] = function()
          vim.notify(
            table.concat({
              "ma: 追加",
              "md: 削除",
              "mr: リネーム",
              "mc: コピー",
              "mm: 移動",
              "mp: ペースト",
              "mf: パスをコピー",
              "E: 全展開",
              "W: 全閉じ",
            }, "\n"),
            vim.log.levels.INFO,
            { title = "neo-tree m-prefix", timeout = 5000 }
          )
        end,
        ["ma"] = "add",
        ["md"] = "delete",
        ["mr"] = "rename",
        -- Why: ホスト間転送は nvim-scp へ移行したため、mc/mp は neo-tree 標準の
        -- クリップボード copy/paste を使用する(旧 fileclip 方式は廃止)
        ["mc"] = "copy_to_clipboard",
        ["mm"] = "move",
        ["mf"] = function(state)
          local path = state.tree:get_node().path
          vim.fn.setreg("+", path)
          local max_len = 50
          local display = #path > max_len and ("..." .. path:sub(-max_len)) or path
          vim.notify("Copied path: " .. display)
        end,
        ["mp"] = "paste_from_clipboard",
        -- Why: トグル時の自動全展開の廃止(73837c7)に伴い、全展開/全閉じを
        -- 手動キーでのみ実行できるよう提供する
        ["E"] = "expand_all_nodes",
        ["W"] = "close_all_nodes",
      },
    },
  },
}
