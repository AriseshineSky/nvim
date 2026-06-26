return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "Avante" },
		opts = {
			file_types = { "markdown", "Avante" },
			code = {
				enable = true,
				sign = true,
			},
		},
	},
	{
		"kevalin/mermaid.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		ft = { "markdown", "mermaid" },
		config = function()
			require("mermaid").setup({
				format = {
					shift_width = vim.o.shiftwidth,
				},
				lint = {
					enabled = vim.fn.executable("mmdc") == 1,
					command = "mmdc",
				},
				preview = {
					renderer = "mermaid.js",
				},
			})

			local function mermaid_maps(buf)
				vim.keymap.set("n", "<leader>mp", "<cmd>MermaidPreview<cr>", { buffer = buf, desc = "Mermaid preview" })
				vim.keymap.set("n", "<leader>mf", "<cmd>MermaidFormat<cr>", { buffer = buf, desc = "Mermaid format" })
				vim.keymap.set("n", "<leader>mr", "<cmd>MermaidRender<cr>", { buffer = buf, desc = "Mermaid render (terminal)" })
				vim.keymap.set("n", "<leader>mc", "<cmd>MermaidCopyURL<cr>", { buffer = buf, desc = "Mermaid copy preview URL" })
				vim.keymap.set("n", "<leader>mx", "<cmd>MermaidPreviewStop<cr>", { buffer = buf, desc = "Mermaid stop preview" })
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "mermaid",
				callback = function(ev)
					mermaid_maps(ev.buf)
				end,
			})
		end,
	},
	{
		"wurli/contextindent.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		ft = { "markdown", "mermaid" },
		opts = {
			-- autocommand pattern must be a string (filename glob), not filetypes
			pattern = "*.md,*.markdown,*.mmd,*.mermaid",
		},
	},
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
				callback = function(ev)
					vim.keymap.set("n", "r", "<cmd>MarkdownPreview<cr>", { buffer = ev.buf, desc = "Markdown preview (browser)" })
				end,
			})
		end,
	},
}
