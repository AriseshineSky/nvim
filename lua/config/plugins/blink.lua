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
			-- 签名帮助：只显示参数行（见 signature.window.show_documentation = false）
			['<C-f>'] = { 'show_signature', 'hide_signature', 'fallback' },
			-- 仅在补全菜单打开时开关文档；否则 fallback（避免抢走 visual-multi 的 <C-k>）
			['<C-k>'] = { 'show_documentation', 'hide_documentation', 'fallback' },
			-- preselect=false 时没有选中项；`accept` 不会插入，`select_and_accept` 会先选第一项再确认（见 :h blink-cmp）
			['<CR>'] = { 'select_and_accept', 'fallback' },
			-- 用 is_menu_visible：is_visible 含 ghost text，此时 select_next 的 can_select 为 false。
			-- 不要在菜单未打开时用 has_words_before + show 并 return true：会吞掉 Tab，无法 fallback 缩进。
			-- 补全触发交给 auto_show / <C-o>（show）。
			['<Tab>'] = {
				function(cmp)
					if cmp.is_menu_visible() then
						cmp.select_next()
						return true
					end
				end,
				'fallback',
			},
			['<S-Tab>'] = {
				function(cmp)
					if cmp.is_menu_visible() then
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
				-- 菜单本身别占太多行
				max_height = 8,
				border = 'rounded',
				winhighlight = 'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
				draw = {
					align_to = 'label',
					padding = { 0, 1 },
					gap = 1,
					cursorline_priority = 0,
					-- 只保留图标 + 名称 + 短类型；去掉 kind 文字 / source，减少横向遮挡
					columns = {
						{ 'kind_icon' },
						{ 'label', 'label_description', gap = 1 },
					},
					components = {
						label = {
							ellipsis = true,
							width = { fill = true, max = 36 },
						},
						label_description = {
							ellipsis = true,
							width = { max = 18 },
							highlight = 'Comment',
						},
					},
				},
			},
			documentation = {
				-- 不自动弹文档；需要看时按 <C-k>，既有提示又不挡输入
				auto_show = false,
				auto_show_delay_ms = 500,
				window = {
					border = 'rounded',
					max_width = 56,
					max_height = 12,
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

		-- 括号内参数提示：自动出一行签名，不附带 RDoc/文档（避免大面积挡代码）
		signature = {
			enabled = true,
			window = {
				border = 'rounded',
				max_width = 80,
				max_height = 4,
				show_documentation = false,
			},
		},
	},
	opts_extend = { "sources.default" }
}
