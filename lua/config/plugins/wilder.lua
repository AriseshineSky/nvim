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
				-- 签名帮助统一交给 blink.cmp（小窗口、show_documentation=false）。
				-- noice 默认会接管 vim.lsp.buf.signature_help 并在输入触发字符时自动弹出
				-- hover 视图（max_height=20，且带 LSP 完整文档），与 blink 的签名窗口重叠、
				-- 大面积遮挡代码，导致无法正常输入方法参数，因此关闭。
				-- 需要手动查看时用 blink 的 <C-f>（show_signature）。
				signature = { enabled = false },
			},
			presets = {
				bottom_search = true,     -- 搜索栏在底部
				command_palette = true,   -- 命令行在屏幕中间
				long_message_to_split = true, -- 长消息自动拆分
				inc_rename = false,       -- 是否接管重命名界面
				lsp_doc_border = false,   -- LSP 文档添加边框
			},
		}
	end
}
