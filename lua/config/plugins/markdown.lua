return {
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
		build = "cd app && npm install",
		ft = { "markdown" },
		init = function()
			vim.g.mkdp_auto_start = 0
		end,
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					-- buffer-local: only in markdown, 'r' opens preview
					vim.keymap.set("n", "r", "<cmd>MarkdownPreview<cr>", { buffer = true, desc = "Markdown preview (browser)" })
				end,
			})
		end,
	},
}
