-- LSP configuration
-- mason.nvim + nvim-lspconfig

return {
  -- Mason: LSP server manager
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>m", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- Mason-lspconfig: Bridge between mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
  },

  -- Lazydev: Neovim Lua development support
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "folke/lazydev.nvim",
    },
    --- nvim-lspconfig の設定関数
    --- LSPサーバーのセットアップ、キーマップ、診断設定を行う
    --- @return nil
    config = function()
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- Enhanced capabilities with nvim-cmp
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- 診断・hover翻訳モジュール(lua/lsp_translator/)
      -- Why: 行末virtual_textとhoverフロートのメッセージ翻訳、visual選択翻訳を
      -- このモジュールが担当する。<leader>hのhover統合フロートも同様
      -- NOTE: virtual_text handlerのwrapは診断表示前に適用する必要があるため
      -- ここ(BufReadPre時)でsetupする
      require("lsp_translator").setup({ source = "auto", target = "ja" })

      -- NOTE: LSP進捗($/progress)の表示はfidget.nvimが担当(plugins/fidget.lua)

      --- スマート定義/参照トグル関数
      --- カーソル位置が定義元の場合は参照一覧を表示し、それ以外の場合は定義にジャンプする
      --- @return nil
      local function smart_definition_or_references()
        local current_buf = vim.api.nvim_get_current_buf()
        local current_pos = vim.api.nvim_win_get_cursor(0)

        -- Get active LSP client for position encoding
        local clients = vim.lsp.get_clients({ bufnr = current_buf })
        if #clients == 0 then
          vim.notify("No LSP client attached", vim.log.levels.WARN)
          return
        end
        local client = clients[1]
        local encoding = client.offset_encoding or "utf-16"
        local params = vim.lsp.util.make_position_params(0, encoding)

        --- 参照一覧を表示する(トリガ位置自身は除外)
        --- @return nil
        local function show_references()
          vim.lsp.buf.references({ includeDeclaration = false }, {
            on_list = function(list)
              -- トリガ位置と同一ファイル・同一行のエントリ(自分自身)を除外
              -- NOTE: 行単位の判定。`ain`部分など列がずれても除外できるようにするため
              local filtered = {}
              for _, entry in ipairs(list.items) do
                if not (entry.bufnr == current_buf and entry.lnum == current_pos[1]) then
                  table.insert(filtered, entry)
                end
              end
              if vim.tbl_isempty(filtered) then
                vim.notify("No references found", vim.log.levels.INFO)
                return
              end
              vim.fn.setqflist({}, " ", { title = list.title, items = filtered })
              vim.cmd("botright copen")
            end,
          })
        end

        vim.lsp.buf_request(current_buf, "textDocument/definition", params, function(err, result)
          if err or not result or vim.tbl_isempty(result) then
            -- No definition found, try references
            show_references()
            return
          end

          -- Normalize result to array
          local definitions = vim.islist(result) and result or { result }
          local def = definitions[1]

          -- Extract definition location
          local def_uri = def.uri or def.targetUri
          local def_range = def.range or def.targetSelectionRange

          if not def_uri or not def_range then
            vim.lsp.buf.definition()
            return
          end

          local def_bufnr = vim.uri_to_bufnr(def_uri)
          local def_line = def_range.start.line + 1

          -- カーソルが定義行上にあるか
          -- NOTE: 列は問わない。定義行のシンボル部分(例: `ain`)で発火した場合、
          -- 列単位の一致判定だと「1文字隣へのジャンプ」になりUXが悪いため
          if def_bufnr == current_buf and def_line == current_pos[1] then
            show_references()
          else
            -- Why: ここでvim.lsp.buf.definition()を呼ぶとdefinition要求が
            -- 2回往復して体感が遅くなるため、1回目の応答結果から直接
            -- ジャンプする(built-in definition handler相当の挙動)
            -- NOTE: jump_to_locationは0.12で削除予定のためshow_documentを使用
            -- Note: 引数の形は旧jump_to_location(location, encoding, reuse_win=true)と
            -- 完全等価(runtime/lua/vim/lsp/util.lua:964 の移行定義)。既に定義バッファを
            -- 開いているウィンドウがあれば新規分割せずそこへ飛ぶ(reuse_win=true)
            vim.lsp.util.show_document(
              { uri = def_uri, range = def_range },
              encoding,
              { reuse_win = true, focus = true }
            )
          end
        end)
      end

      -- quickfixウィンドウの操作改善
      -- - アイテム移動時: 自動でpreview表示
      -- - 項目選択後ジャンプ時 / <Esc>時: quickfixとpreviewを閉じる
      -- NOTE: LSP参照一覧以外のquickfix(grep等)でも同様の挙動となる
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserQuickfixClose", {}),
        pattern = "qf",
        callback = function(args)
          --- previewウィンドウのwinidを返す。存在しない場合はnil
          --- @return integer|nil winid
          local function find_preview_win()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              if vim.api.nvim_get_option_value("previewwindow", { win = win }) then
                return win
              end
            end
          end

          -- カーソル行をハイライトして追従を視認できるようにする
          vim.opt_local.cursorline = true
          -- カーソル行のエントリへジャンプしてquickfix/previewを閉じる
          -- NOTE: 組込み<CR>経由はマウス文脈でジャンプが落ちるため、明示的に:.ccを使う
          -- NOTE: pcloseを先に実行する。ジャンプ後に閉じると、ジャンプ先ウィンドウとして
          -- preview windowが選択され、ジャンプ結果がpcloseで巻き戻るように見える
          local jump_close = ":pclose<CR>:.cc<CR>:cclose<CR>"
          local opts = { buffer = args.buf, silent = true }
          vim.keymap.set("n", "<CR>", jump_close, opts)
          vim.keymap.set("n", "<LeftRelease>", jump_close, opts)
          vim.keymap.set("n", "<Esc>", ":cclose<CR>:pclose<CR>", opts)
          -- Why: <C-n>/<C-p>はbufferlineがグローバルにバッファ切替へ割り当て済み
          -- (nvim/lua/plugins/bufferline.lua keys)。quickfixウィンドウ内では
          -- エントリ移動に使いたいため、バッファローカルで上書きする
          vim.keymap.set("n", "<C-n>", "j", opts)
          vim.keymap.set("n", "<C-p>", "k", opts)
          vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = args.buf,
            callback = function()
              -- カーソル位置のqfアイテムをpreviewウィンドウに表示
              -- NOTE: 組込み`p`マッピングをnormal経由で実行するとpaste扱いになり
              -- E21(modifiable off)が出るため、APIで直接実現する
              -- NOTE: 毎回peditするとqf側のカーソルが先頭行へ戻るため、
              -- preview未開始または対象ファイルが変わるときのみpeditする
              -- qfの「現在のエントリ」(getqflist idx)はジャンプ時にしか更新されないため、
              -- カーソル行からアイテムを引く(qfは1行=1アイテム)
              local line = vim.api.nvim_win_get_cursor(0)[1]
              local items = vim.fn.getqflist({ items = 0 }).items
              local item = items and items[line]
              if not item or item.bufnr == 0 then
                return
              end
              local pwin = find_preview_win()
              if not pwin or vim.api.nvim_win_get_buf(pwin) ~= item.bufnr then
                vim.cmd.pedit(vim.fn.fnameescape(vim.api.nvim_buf_get_name(item.bufnr)))
                pwin = find_preview_win()
              end
              if pwin then
                -- NOTE: win_callによる一時的なカレントウィンドウ切替は、マウスイベント処理と
                -- 交錯して不具合の温床になるため使わない。win_set_cursorのみで表示を追従させる
                vim.api.nvim_win_set_cursor(pwin, { math.max(item.lnum, 1), math.max(item.col - 1, 0) })
              end
            end,
          })
        end,
      })

      --- 診断メッセージのナビゲーション関数を生成する
      --- @param direction "next"|"prev" 移動方向("next"で次へ、それ以外で前へ)
      --- @return function 診断メッセージにジャンプする関数
      local function goto_diagnostic(direction)
        local count = direction == "next" and 1 or -1
        return function()
          vim.diagnostic.jump({ count = count, float = true })
        end
      end

      -- Why: 診断+hover統合フロート(翻訳つき)はlsp-translator.nvim(plugins/translate.lua)
      -- が提供する。行末virtual_textの翻訳も同プラグインが担当する

      -- Keymaps on LSP attach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }

          -- Smart definition/references
          vim.keymap.set("n", "<leader>d", smart_definition_or_references, opts)

          -- Jump back
          vim.keymap.set("n", "<leader>b", "<C-o>", opts)

          -- Hover documentation (診断全文を併載・翻訳はlsp-translator.nvim)
          -- Why: 結果フロートが開いているときはhoverではなくフロートへの
          -- 突入(スクロール読み)を優先する。<leader>h二度押しで突入できる
          vim.keymap.set("n", "<leader>h", function()
            local translator = require("lsp_translator")
            if not translator.focus_float() then
              translator.hover()
            end
          end, opts)

          -- Rename
          vim.keymap.set("n", "<leader>n", vim.lsp.buf.rename, opts)

          -- Code action (VSCode QuickFix相当)
          -- Why: <M-.> はmacOS(Ghostty option-as-alt)とWindows(WezTerm+psmux、Alt+キーは
          --      ESC前置形式でConPTYを通る)の両方で素通るため共通キー
          vim.keymap.set({ "n", "v" }, "<M-.>", vim.lsp.buf.code_action, opts)

          -- Diagnostic navigation
          vim.keymap.set("n", "[d", goto_diagnostic("prev"), opts)
          vim.keymap.set("n", "]d", goto_diagnostic("next"), opts)
        end,
      })

      -- Diagnostic display settings
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 2,
        },
        -- Why: sign textはテキスト文字で指定する(Nerd Fontグリフは環境依存で空白化した実績あり)
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✖",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "■",
            [vim.diagnostic.severity.INFO] = "■",
          },
        },
        underline = true,
        -- Why: 挿入モード中も診断表示を更新し、VSCode/markdownlint(nvim-lint)と
        -- 同じ逐次診断の体感に揃えるため
        update_in_insert = true,
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })

      --- LSPサーバーのセットアップを行う
      --- サーバー固有のsettingsはlua/lsp/配下の言語モジュールから供給される
      -- Why: nvim-lspconfigのrequire("lspconfig")[server].setup()は非推奨互換層で
      -- settingsが正しく渡らないため、nvim 0.11流のvim.lsp.configを使う。
      -- mason-lspconfigはsetup時にサーバーを自動enableするため、
      -- それより前にvim.lsp.configでsettingsを適用しておく必要がある
      local lsp = require("lsp")
      -- Why: handlers廃止に伴い、cmp_nvim_lspのcapabilitiesをサーバーへ渡す経路は
      -- このループしか存在しない。settingsを持つサーバーだけを対象にすると、
      -- 残りのサーバーはcapabilities無しで自動enableされ補完連携が欠落する
      -- (mason-lspconfig v2はsettings.luaのautomatic_enable=trueがデフォルトで
      -- setup時にmason導入済み全サーバーをenableするため、このループでの事前configが必須)
      for _, server in ipairs(lsp.servers) do
        vim.lsp.config(server, {
          capabilities = capabilities,
          settings = lsp.lsp_settings[server],
        })
      end
      -- Why: rust_analyzer等mason管理外(rustup等)サーバーはmason-lspconfigの
      -- 自動enable対象にならないため、全サーバーを明示的にenableする
      -- (mason管理サーバーと重複enableしても無害)
      vim.lsp.enable(lsp.servers)

      -- Setup mason-lspconfig
      -- サーバー一覧はlua/lsp/配下の言語モジュールから供給される
      require("mason-lspconfig").setup({
        -- Note: require("lsp")のロード時に各言語モジュールのon_setup()が実行され、
        -- ruff自動フォーマット用autocmd(nvim/lua/lsp/python.lua)が登録される。
        -- つまりrequire("lsp")はサーバー一覧の取得とautocmd登録の両方を担う
        ensure_installed = lsp.mason_servers,
        automatic_installation = true,
      })
    end,
  },
}
