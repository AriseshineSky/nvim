return {
	"yetone/avante.nvim",
	-- 如果您想从源代码构建，请执行 `make BUILD_FROM_SOURCE=true`
	-- ⚠️ 一定要加上这一行配置！！！！！
	lazy = false,
	build = vim.fn.has("win32") ~= 0
			and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
			or "make",
	event = "VeryLazy",
	version = false, -- 永远不要将此值设置为 "*"！永远不要！
	---@module 'avante'
	---@type avante.Config
	opts = {
		provider = "deepseek",
		providers = {
			deepseek = {
				__inherited_from = "openai", -- 必须：告诉 avante 使用 OpenAI 的请求格式
				endpoint = "https://api.deepseek.com",
				model = "deepseek-chat",
				api_key_name = "DEEPSEEK_API_KEY", -- 显式指定寻找的环境变量名
				timeout = 30000,
				max_tokens = 8192,
			},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- 以下依赖项是可选的，
		"echasnovski/mini.pick",       -- 用于文件选择器提供者 mini.pick
		"nvim-telescope/telescope.nvim", -- 用于文件选择器提供者 telescope
		"hrsh7th/nvim-cmp",            -- avante 命令和提及的自动完成
		"ibhagwan/fzf-lua",            -- 用于文件选择器提供者 fzf
		"nvim-tree/nvim-web-devicons", -- 或 echasnovski/mini.icons
		"zbirenbaum/copilot.lua",      -- 用于 providers='copilot'
		{
			-- 支持图像粘贴
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				-- 推荐设置
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- Windows 用户必需
					use_absolute_path = true,
				},
			},
		},
		{
			-- 如果您有 lazy=true，请确保正确设置
			'MeanderingProgrammer/render-markdown.nvim',
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
