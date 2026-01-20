return {
	"nvim-treesitter/playground",
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		priority = 1000,
		build = ":TSUpdate",
		config = function()
			vim.opt.smartindent = false
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				sync_install = false,
				ensure_installed = {
					"asm",
					"markdown",
					"html",
					"javascript",
					"typescript",
					"tsx",
					"query",
					"c",
					"prisma",
					"bash",
					"go",
					"lua",
					"kdl",
					"vim",
					"terraform",
					"dockerfile",
					"yaml",
					"python",
					"ruby"
				},
				highlight = {
					enable = true,
					disable = function(lang, bufnr)
						-- local filename = vim.api.nvim_buf_get_name(bufnr)
						-- return lang == "c" or filename:match("%.h$")
					end,
				},
				indent = {
					enable = true,
					disable = function(lang, bufnr)
						local disallowed_filetypes = { "yaml", "ruby", "python" }
						return vim.tbl_contains(disallowed_filetypes, lang)
					end,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection    = "<c-n>",
						node_incremental  = "<c-n>",
						node_decremental  = "<c-h>",
						scope_incremental = "<c-l>",
					},
				}
			})
		end
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			local tscontext = require('treesitter-context')
			tscontext.setup {
				enable = true,
				max_lines = 0,        -- How many lines the window should span. Values <= 0 mean no limit
				min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
				line_numbers = true,
				multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
				trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				mode = 'cursor',      -- Line used to calculate context. Choices: 'cursor', 'topline'
				-- Separator between context and content. Should be a single character string, like '-'.
				-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
				separator = "-",
				zindex = 20, -- The Z-index of the context window
				-- on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
				on_attach = function(bufnr)
					-- local ft = vim.bo[bufnr].filetype
					-- local ok = require("nvim-treesitter.parsers").has_parser(ft)
					-- return ok
					local ft = vim.bo[bufnr].filetype
					local has_parser = require("nvim-treesitter.parsers").has_parser(ft)
					local parser = has_parser and vim.treesitter.get_parser(bufnr, ft)
					local tree = parser and parser:parse()[1]
					local root = tree and tree:root()
					return root ~= nil
				end,

			}
			vim.keymap.set("n", "[c", function()
				tscontext.go_to_context()
			end, { silent = true })
		end
	},
}
