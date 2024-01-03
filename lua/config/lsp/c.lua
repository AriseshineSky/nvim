return {
	setup = function(lspconfig, lsp)
		lspconfig.clangd.setup({
			-- on_attach = function()
			-- end,
			filetypes = { "c", "cpp" }
		})
	end
}
