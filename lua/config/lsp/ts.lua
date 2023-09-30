return {
	setup = function(lspconfig, lsp)
		lspconfig.tsserver.setup({
			-- on_attach = function()
			-- end,
			-- filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" }
		})
	end
}
