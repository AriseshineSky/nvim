return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,   -- 配色方案通常不建议延迟加载
	priority = 1000, -- 确保在其他插件之前加载
	config = function()
		require("catppuccin").setup({
			flavour = "mocha",           -- 明确指定使用 Mocha 变体
			transparent_background = false, -- 如果需要背景透明可以改为 true
			term_colors = true,
			integrations = {
				treesitter = true,
				native_lsp = {
					enabled = true,
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
					},
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
				},
				-- 如果你使用了 nvim-treesitter-context，开启这个集成
				treesitter_context = true,
			},
			-- 这里是你之前的自定义高亮逻辑
			custom_highlights = function(colors)
				return {
					-- Treesitter Context 设置
					TreesitterContext = { bg = "#353b45", fg = "#ebdbb2" },
					TreesitterContextSeparator = { fg = "#4a505c", bg = "#353b45" },

					-- 修改代码提示 (LSP Diagnostics) 背景颜色
					-- 注意：Catppuccin 默认其实已经处理得很好了，
					-- 如果你想保持原本 deus 的深灰色背景 (#282c34)，可以用下面的代码：
					LspDiagnosticsVirtualTextError = { bg = "#282c34", fg = colors.red },
					LspDiagnosticsVirtualTextWarning = { bg = "#282c34", fg = colors.yellow },
					LspDiagnosticsVirtualTextInformation = { bg = "#282c34", fg = colors.blue },
					LspDiagnosticsVirtualTextHint = { bg = "#282c34", fg = colors.teal },

					-- LSP 浮动窗口背景颜色
					NormalFloat = { bg = "#2c313c" },

					-- WinBar 设置
					WinBar = { bg = "NONE", fg = "#c0caf5" },
					WinBarNC = { bg = "NONE", fg = "#565f89" },
				}
			end,
		})

		-- 最终激活主题
		vim.cmd.colorscheme "catppuccin"
	end,
}
-- return {
-- 	"theniceboy/nvim-deus",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 		vim.cmd([[colorscheme deus]])
-- 		vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#353b45", fg = "#ebdbb2" })
-- 		vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#4a505c", bg = "#353b45" })
--
-- 		-- 修改代码提示背景颜色
-- 		vim.api.nvim_set_hl(0, "LspDiagnosticsVirtualTextError", { bg = "#282c34", fg = "#e06c75" })
-- 		vim.api.nvim_set_hl(0, "LspDiagnosticsVirtualTextWarning", { bg = "#282c34", fg = "#e5c07b" })
-- 		vim.api.nvim_set_hl(0, "LspDiagnosticsVirtualTextInformation", { bg = "#282c34", fg = "#61afef" })
-- 		vim.api.nvim_set_hl(0, "LspDiagnosticsVirtualTextHint", { bg = "#282c34", fg = "#98c379" })
--
-- 		-- 设置 Treesitter 高亮
-- 		vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#353b45", fg = "#ebdbb2" })
-- 		vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#4a505c", bg = "#353b45" })
--
-- 		-- 设置 LSP 窗口背景颜色（如果需要）
-- 		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#2c313c" })
--
-- 		vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE", fg = "#c0caf5" }) -- 前景色根据主题改
-- 		vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE", fg = "#565f89" })
-- 	end,
-- }
