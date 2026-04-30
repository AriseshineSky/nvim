return {
	-- playground 已归档；用内置 :Inspect / :InspectTree / :EditQuery
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		priority = 1000,
		branch = "main",
		build = ":TSUpdate",
		config = function()
			vim.opt.smartindent = false

			require("nvim-treesitter").setup()

			local ensure_installed = {
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
				"ruby",
				-- *.erb → filetype eruby；需 embedded_template，仅有 ruby 解析器不会高亮 ERB
				"embedded_template",
			}

			-- 必须指定 "parsers"；无参 get_installed 会合并 queries 目录名，误判为已装而跳过 install
			local installed = require("nvim-treesitter").get_installed("parsers")
			local parsers_to_install = vim.tbl_filter(function(name)
				return not vim.tbl_contains(installed, name)
			end, ensure_installed)
			if #parsers_to_install > 0 then
				require("nvim-treesitter").install(parsers_to_install)
			end

			-- 不用 Makefile：卸掉 make parser（避免坏掉的 make.so / 不需要 TS 高亮）
			do
				local ok, plist = pcall(require("nvim-treesitter").get_installed, "parsers")
				if ok and vim.tbl_contains(plist, "make") then
					pcall(function()
						require("nvim-treesitter").uninstall("make"):wait(120000)
					end)
				end
			end

			local no_ts_indent = { yaml = true, ruby = true, python = true }

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function(ev)
					if ev.match == "make" then
						return
					end
					if not pcall(vim.treesitter.start) then
						return
					end
					if not no_ts_indent[vim.bo.filetype] then
						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			-- Neovim 0.12：match 里可能是 node 列表；兼容 markdown fenced info string 注入
			local query = require("vim.treesitter.query")
			local non_filetype_match_injection_language_aliases = {
				ex = "elixir",
				pl = "perl",
				sh = "bash",
				uxn = "uxntal",
				ts = "typescript",
			}
			local function get_parser_from_markdown_info_string(injection_alias)
				local match_ft = vim.filetype.match({ filename = "a." .. injection_alias })
				return match_ft or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
			end
			query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
				local capture_id = pred[2]
				local node = match[capture_id]
				if type(node) == "table" then
					node = node[1]
				end
				if not node then
					return
				end
				local text = vim.treesitter.get_node_text(node, bufnr)
				if not text then
					return
				end
				metadata["injection.language"] = get_parser_from_markdown_info_string(text:lower())
			end, { force = true, all = false })

			-- 旧版 incremental_selection（<C-n> 等）在 main 已移除。Nvim 0.12 内置选区：Visual 下见 :help v_in、:help v_an
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			local tscontext = require("treesitter-context")
			tscontext.setup({
				enable = true,
				max_lines = 0,
				min_window_height = 0,
				line_numbers = true,
				multiline_threshold = 20,
				trim_scope = "outer",
				mode = "cursor",
				separator = "-",
				zindex = 20,
				on_attach = function(bufnr)
					local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
					if not ok or not parser then
						return false
					end
					local tree = parser:parse()[1]
					local root = tree and tree:root()
					return root ~= nil
				end,
			})
			vim.keymap.set("n", "[c", function()
				tscontext.go_to_context(vim.v.count1)
			end, { silent = true })
		end,
	},
}
