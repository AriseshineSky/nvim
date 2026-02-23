return {
	setup = function()
		require("neodev").setup({
			lspconfig = true,
			override = function()
			end,
		})

		vim.lsp.config("lua_ls", {
			on_attach = function()
			end,
			settings = {
				Lua = {
					diagnostics = {
						globals = {
							"vim",
							"require",
						},
					},
					workspace = {
						checkThirdParty = false,
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})
	end,
}
