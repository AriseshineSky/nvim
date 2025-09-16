return {
	"theniceboy/nvim-deus",
	lazy = false,
	priority = 1000,
	config = function()
		vim.cmd([[colorscheme deus]])
		vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#353b45", fg = "#ebdbb2" })
		vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#4a505c", bg = "#353b45" })

		-- 修改代码提示背景颜色
		vim.api.nvim_set_hl(0, "LspDiagnosticsVirtualTextError", { bg = "#282c34", fg = "#e06c75" })
		vim.api.nvim_set_hl(0, "LspDiagnosticsVirtualTextWarning", { bg = "#282c34", fg = "#e5c07b" })
		vim.api.nvim_set_hl(0, "LspDiagnosticsVirtualTextInformation", { bg = "#282c34", fg = "#61afef" })
		vim.api.nvim_set_hl(0, "LspDiagnosticsVirtualTextHint", { bg = "#282c34", fg = "#98c379" })

		-- 设置 Treesitter 高亮
		vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#353b45", fg = "#ebdbb2" })
		vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#4a505c", bg = "#353b45" })

		-- 设置 LSP 窗口背景颜色（如果需要）
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#2c313c" })

		vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE", fg = "#c0caf5" }) -- 前景色根据主题改
		vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE", fg = "#565f89" })
	end,
}
