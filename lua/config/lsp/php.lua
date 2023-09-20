return {
	setup = function(lspconfig, lsp)
		vim.cmd([[
			autocmd FileType php setlocal tabstop=4
			autocmd FileType php setlocal shiftwidth=4
			autocmd FileType php setlocal expandtab
		]])
		lspconfig.intelephense.setup({
			on_attach = function()
			end,
			filetypes = { 'php' },
		})
	end
}
