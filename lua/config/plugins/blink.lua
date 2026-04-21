local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return {
	'saghen/blink.cmp',
	init = function()
		vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { fg = '#D8DEE9', bg = '#2E3440' })
		vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { fg = '#4C566A', bg = '#2E3440' })
		vim.api.nvim_set_hl(0, 'BlinkCmpMenuSelection', { bg = '#3B4252' })
		vim.api.nvim_set_hl(0, 'BlinkCmpDoc', { fg = '#D8DEE9', bg = '#2E3440' })
		vim.api.nvim_set_hl(0, 'BlinkCmpDocBorder', { fg = '#4C566A', bg = '#2E3440' })
		vim.api.nvim_set_hl(0, 'BlinkCmpLabelMatch', { fg = '#82AAFF', bold = true })
		vim.api.nvim_set_hl(0, 'BlinkCmpLabelDeprecated', { fg = '#7E8294', strikethrough = true })
		vim.api.nvim_set_hl(0, 'BlinkCmpLabelDescription', { fg = '#808080', italic = true })
		vim.api.nvim_set_hl(0, 'BlinkCmpSource', { fg = '#808080', italic = true })
	end,

	-- use a release tag to download pre-built binaries
	version = '1.*',
	-- AND/OR build from source
	-- build = 'cargo build --release',
	-- If you use nix, you can build from source with:
	-- build = 'nix run .#build-plugin',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = 'none',
			['<C-o>'] = { 'show' },
			['<C-e>'] = { function() return true end },
			['<C-n>'] = { function() return true end },
			['<C-y>'] = { 'fallback' },
			['<C-u>'] = { 'fallback' },
			['<C-f>'] = { 'hide', 'fallback' },
			['<CR>'] = {
				function(cmp)
					if cmp.is_visible() then
						cmp.accept()
						return true
					end
				end,
				'fallback',
			},
			['<Tab>'] = {
				function(cmp)
					if cmp.is_visible() then
						cmp.select_next()
						return true
					end
					if has_words_before() then
						cmp.show()
						return true
					end
				end,
				'fallback',
			},
			['<S-Tab>'] = {
				function(cmp)
					if cmp.is_visible() then
						cmp.select_prev()
						return true
					end
				end,
				'fallback',
			},
		},

		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = 'mono',
			use_nvim_cmp_as_default = true,
		},

		completion = {
			menu = {
				auto_show = true,
				border = 'rounded',
				winhighlight = 'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
				draw = {
					align_to = 'label',
					padding = 0,
					gap = 0,
					cursorline_priority = 0,
					columns = {
						{ 'kind_icon', 'kind' },
						{ 'label', 'label_description', gap = 1 },
						{ 'source_name', gap = 1 },
					},
					components = {
						label = {
							ellipsis = true,
						},
						label_description = {
							highlight = 'Comment',
						},
						source_name = {
							highlight = 'Comment',
						},
					},
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 0,
				window = {
					border = 'rounded',
					winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc',
				},
			},
			list = { selection = { preselect = false, auto_insert = false } },
			accept = { auto_brackets = { enabled = false } },
		},

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = { 'lsp', 'buffer', 'path' },
			per_filetype = {
				lua = { inherit_defaults = true, 'lazydev' },
			},
			transform_items = function(_, items)
				local item_kind = require('blink.cmp.types').CompletionItemKind.Snippet
				return vim.tbl_filter(function(item)
					return item.kind ~= item_kind
				end, items)
			end,
		},

		-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
		-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
		-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
		--
		-- See the fuzzy documentation for more information
		fuzzy = { implementation = "prefer_rust_with_warning" },

		signature = { enabled = false },
	},
	opts_extend = { "sources.default" }
}
