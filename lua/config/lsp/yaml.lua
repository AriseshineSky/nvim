return {
	setup = function(lspconfig, lsp)
		lspconfig.yamlls.setup({
			-- on_attach = function()
			-- end,
			filetypes = { "yml", "yaml" }
		})
	end
}
