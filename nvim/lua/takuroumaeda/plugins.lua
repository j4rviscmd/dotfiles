vim.cmd [[packadd packer.nvim]]

local status, packer = pcall(require, "packer")
if not status then
    print "Packer is not installed"
    return
end

return packer.startup(function(use)
    use { "wbthomason/packer.nvim" }

    -- Startup screen
    use {
        "eoh-bse/minintro.nvim",
        config = function()
            require("minintro").setup()
        end,
    }

    -- Easy motion
    use {
        "phaazon/hop.nvim",
        branch = "v2", -- optional but strongly recommended
    }

    -- When if you yanked, highlight
    use "machakann/vim-highlightedyank"

    -- enable git command to neovim
    -- use 'tpope/vim-fugitive'

    -- Show file icons
    use "ryanoasis/vim-devicons"

    -- Icon
    use "kyazdani42/nvim-web-devicons"

    -- Show git diff sign leftmost column
    use "lewis6991/gitsigns.nvim"

    -- Commentary
    use "tpope/vim-commentary"

    use "ConradIrwin/vim-bracketed-paste"

    -- Solarized dark theme
    use {
        "maxmx03/solarized.nvim",
    }

    use {
        "nvim-treesitter/nvim-treesitter",
        run = function()
            local ts_update = require("nvim-treesitter.install").update { with_sync = true }
            ts_update()
        end,
    }

    -- git source controller
    -- TODO packer向けインストール手順公開され次第FIX
    -- use {'SuperBo/fugit2.nvim',
    --   opts = {
    --     libgit2_path = '/opt/homebrew/lib/libgit2.dylib'
    --   },
    --   requires = {
    --     {'MunifTanjim/nui.nvim'},
    --     { "nvim-tree/nvim-web-devicons" },
    --     {'nvim-lua/plenary.nvim'},
    --   },
    -- }

    use {
        "akinsho/bufferline.nvim",
        -- https://github.com/akinsho/bufferline.nvim/issues/903
        -- tag = "*",
        requires = "nvim-tree/nvim-web-devicons",
    }

    -- Theme for editor bottom
    use "nvim-lualine/lualine.nvim"

    -- Preview for markdown file
    -- TODO move to config file.
    use {
        "iamcco/markdown-preview.nvim",
        run = function()
            vim.fn["mkdp#util#install"]()
        end,
        config = function()
            vim.g["mkdp_auto_start"] = 0
            vim.g["mkdp_auto_close"] = 1
            vim.g["mkdp_refresh_slow"] = 0
            vim.g["mkdp_command_for_global"] = 0
            vim.g["mkdp_open_to_the_world"] = 0
            vim.g["mkdp_open_ip"] = ""
            vim.g["mkdp_browser"] = ""
            vim.g["mkdp_echo_preview_url"] = 0
            vim.g["mkdp_browserfunc"] = ""
            vim.g["mkdp_preview_options"] = {
                ["mkit"] = {},
                ["katex"] = {},
                ["uml"] = {},
                ["maid"] = {},
                ["disable_sync_scroll"] = 0,
                ["sync_scroll_type"] = "relative",
                ["hide_yaml_meta"] = 1,
                ["sequence_diagrams"] = {},
                ["flowchart_diagrams"] = {},
                ["content_editable"] = "v:false",
                ["disable_filename"] = 0,
                ["toc"] = {},
            }
            vim.g["mkdp_markdown_css"] = ""
            vim.g["mkdp_highlight_css"] = ""
            vim.g["mkdp_page_title"] = ""
            vim.g["mkdp_filetypes"] = { "markdown" }
            vim.g["mkdp_theme"] = "dark"
        end,
    }

    -- prettier
    -- use({
    --   "prettier/vim-prettier",
    --   run = "npm install",
    -- })

    use {
        "windwp/nvim-autopairs",
        config = function()
            require "nvim-autopairs"
        end,
    }

    use {
        "windwp/nvim-ts-autotag",
        config = function()
            require "nvim-treesitter"
        end,
    }

    use {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.6",
        requires = { { "nvim-lua/plenary.nvim" } },
    }

    use "nvim-telescope/telescope-file-browser.nvim"

    -- im-select
    -- Enable macOS only
    if vim.loop.os_uname().sysname == "Darwin" then
        use "keaising/im-select.nvim"
    end

    -- LSP source for nvim-cmp
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-buffer"
    use "hrsh7th/nvim-cmp"

    -- VSCode like pictograms
    use "onsails/lspkind-nvim"

    -- LSP
    use "neovim/nvim-lspconfig"
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"

    -- LSP UIs: Lspsaga
    use {
        "nvimdev/lspsaga.nvim",
        after = "nvim-lspconfig",
    }

    -- Linter, Formatter
    use "jay-babu/mason-null-ls.nvim"
    use {
        "nvimtools/none-ls.nvim",
        requires = {
            { "nvim-lua/plenary.nvim" },
        },
    }

    -- Snipet engine
    use "L3MON4D3/LuaSnip"

    use "folke/lsp-colors.nvim"

    -- Loading UI
    use "j-hui/fidget.nvim"

    -- use("steven-liou/lsp_lines.nvim")
    -- use("antoinemadec/FixCursorHold.nvim")

    -- Show indent
    use "lukas-reineke/indent-blankline.nvim"

    use {
        "kmontocam/nvim-conda",
        requires = { "nvim-lua/plenary.nvim" },
    }
end)
