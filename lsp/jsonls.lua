return {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = true

		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ bufnr = bufnr })
		end, { buffer = bufnr })
	end
}
