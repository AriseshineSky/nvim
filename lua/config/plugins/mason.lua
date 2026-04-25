return {
	"williamboman/mason-lspconfig.nvim",
	lazy = false,
	dependencies = {
		{ "williamboman/mason.nvim", build = ":MasonUpdate", },
	},
	config = function()
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗"
				}
			}
		})
		require("mason-lspconfig").setup({
			ensure_installed = { "lua_ls",
				"pyright",
				"cssls",
				'ts_ls',
				'eslint',
				'jsonls',
				'html',
				'clangd',
				'ruff',
				'yamlls',
				'emmet_language_server',
				'solargraph'
			},
			automatic_installation = false,
		})
	end
}
