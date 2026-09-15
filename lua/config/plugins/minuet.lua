return {
	"milanglacier/minuet-ai.nvim",
	event = "InsertEnter",
	config = function()
		require("minuet").setup {
			provider = "openai_compatible",
			provider_options = {
				openai_compatible = {
					api_key = "XAI_API_KEY",
					end_point = "https://api.x.ai/v1/chat/completions",
					model = "grok-build-0.1",
					name = "Grok",
					optional = {
						max_tokens = 256,
					},
				},
			},
			throttle = 1500,
			debounce = 600,
			virtualtext = {
				auto_trigger_ft = { "*" },
				keymap = {
					accept = "<A-t>",
					accept_line = "<A-d>",
					next = "<A-j>",
					prev = "<A-k>",
					dismiss = "<A-h>",
				},
			},
		}
	end,
}