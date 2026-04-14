return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify", -- 可选
	},
	opts = {
		-- 你的配置
	},
	config = function()
		local noice = require('noice')
		noice.setup {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,                 -- 搜索栏在底部
				command_palette = true,               -- 命令行在屏幕中间
				long_message_to_split = true,         -- 长消息自动拆分
				inc_rename = false,                   -- 是否接管重命名界面
				lsp_doc_border = false,               -- LSP 文档添加边框
			},
		}
	end
}
