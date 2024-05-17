local status, mason = pcall(require, "mason")
if not status then
	print("mason is not installed.")
	return
end

local status2, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status2 then
	print("mason-spconfig is not installed.")
	return
end

local status3, lspconfig = pcall(require, "lspconfig")
if not status3 then
	print("lspconfig is not installed.")
	return
end

-- if status3 then
--   -- lspconfig の内容を vim.inspect で出力
--   print(vim.inspect(lspconfig))
-- else
--   print("Failed to load lspconfig")
-- end

mason.setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

mason_lspconfig.setup({
	ensure_installed = {
		"tsserver",
		"lua_ls",
	},
	automatic_installation = true,
})

mason_lspconfig.setup_handlers({
	-- LSPの一括登録
	function(server_name)
		lspconfig[server_name].setup({})
	end,

	-- 個別登録
	lua_ls = function()
		lspconfig.lua_ls.setup({
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
		})
	end,
})
