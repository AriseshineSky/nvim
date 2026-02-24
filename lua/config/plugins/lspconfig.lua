local M = {}

local F = {}

local documentation_window_open = false

M.config = {
	{
		'weilbith/nvim-code-action-menu',
		cmd = 'CodeActionMenu',
	},
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		dependencies = {
			{
				"folke/trouble.nvim",
				opts = {
					use_diagnostic_signs = true,
					action_keys = {
						close = "<esc>",
						previous = "u",
						next = "e"
					},
				},
			},
			{
				'williamboman/mason.nvim',
				build = function()
					vim.cmd([[MasonInstall]])
				end,
			},
			{ 'hrsh7th/cmp-nvim-lsp' },
			{
				'j-hui/fidget.nvim',
				tag = "legacy"
			},
			"folke/neodev.nvim",
			"ray-x/lsp_signature.nvim",
			"airblade/vim-rooter",
			"b0o/schemastore.nvim",
		},

		config = function()
			local lsp = require('lsp-zero').preset({})
			M.lsp = lsp

			require('mason').setup({})

			-- require('mason-lspconfig').setup({
			-- 	ensure_installed = {
			-- 		"cssls",
			-- 		'ts_ls',
			-- 		'eslint',
			-- 		'jsonls',
			-- 		'html',
			-- 		'clangd',
			-- 		'ruff',
			-- 		'yamlls',
			-- 		'emmet_language_server',
			-- 		'solargraph'
			-- 	},
			-- })


			lsp.on_attach(function(client, bufnr)
				if client.name == "ts_ls" and vim.bo[bufnr].filetype ~= "javascript" then
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
				end
				lsp.default_keymaps({ buffer = bufnr })
				client.server_capabilities.semanticTokensProvider = nil
				require("config.plugins.autocomplete").configfunc()
				require("lsp_signature").on_attach(F.signature_config, bufnr)
				vim.diagnostic.config({
					severity_sort = true,
					underline = true,
					signs = true,
					virtual_text = false,
					update_in_insert = false,
					float = true,
				})

				lsp.set_sign_icons({
					error = '✘',
					warn = '▲',
					hint = '⚑',
					info = '»'
				})
			end)

			lsp.set_server_config({
				on_init = function(client)
					client.server_capabilities.semanticTokensProvider = nil
				end,
			})

			lsp.format_on_save({
				format_opts = {
					-- async = false,
					-- timeout_ms = 10000,
				},
			})




			-- require 'lspconfig'.cssls.setup {}

			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				pattern = { "*.hcl" },
				callback = function()
					local bufnr = vim.api.nvim_get_current_buf()
					local filename = vim.api.nvim_buf_get_name(bufnr)
					vim.fn.system(string.format("packer fmt %s", vim.fn.shellescape(filename)))
					vim.cmd("edit!")
				end,
			})

			lsp.setup()


			-- Neovim hasn't added foldingRange to default capabilities, users must add it manually
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true
			}

			require("fidget").setup({})

			F.configureDocAndSignature()
			F.configureKeybinds()

			local format_on_save_filetypes = {
				json = true,
				lua = true,
				html = true,
				css = true,
				javascript = true,
				typescript = true,
				typescriptreact = true,
				-- c = true,
				-- cpp = true,
				toml = true,
				-- ruby = true,
				-- python = true,
			}
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function()
					if format_on_save_filetypes[vim.bo.filetype] then
						local lineno = vim.api.nvim_win_get_cursor(0)
						vim.lsp.buf.format({ async = false })
						pcall(vim.api.nvim_win_set_cursor, 0, lineno)
					end
				end,
			})
		end
	},
}

F.configureDocAndSignature = function()
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
		vim.lsp.handlers.signature_help, {
			-- silent = true,
			focusable = false,
			border = "rounded",
			zindex = 60,
		}
	)
	local group = vim.api.nvim_create_augroup("lsp_diagnostics_hold", { clear = true })
	vim.api.nvim_create_autocmd({ "CursorHold" }, {
		pattern = "*",
		callback = function()
			if not documentation_window_open then
				vim.diagnostic.open_float(0, {
					scope = "cursor",
					focusable = false,
					zindex = 10,
					close_events = {
						"CursorMoved",
						"CursorMovedI",
						"BufHidden",
						"InsertCharPre",
						"InsertEnter",
						"WinLeave",
						"ModeChanged",
					},
				})
			end
		end,
		group = group,
	})
	-- vim.api.nvim_create_autocmd({ "CursorHoldI" }, {
	-- 	pattern = "*",
	-- 	command = "silent! lua vim.lsp.buf.signature_help()",
	-- 	group = group,
	-- })

	-- F.signature_config = {
	-- 	bind = false,
	-- 	floating_window = true,
	-- 	hint_inline = function() return false end,
	-- 	handler_opts = {
	-- 		border = "rounded"
	-- 	}
	-- }
	-- local lspsignature = require('lsp_signature')
	-- lspsignature.setup(F.signature_config)
end

local documentation_window_open_index = 0
local function show_documentation()
	documentation_window_open_index = documentation_window_open_index + 1
	local current_index = documentation_window_open_index
	documentation_window_open = true
	vim.defer_fn(function()
		if current_index == documentation_window_open_index then
			documentation_window_open = false
		end
	end, 500)
	vim.lsp.buf.hover()
end

F.configureKeybinds = function()
	vim.api.nvim_create_autocmd('LspAttach', {
		desc = 'LSP actions',
		callback = function(event)
			local opts = { buffer = event.buf, noremap = true, nowait = true }

			vim.keymap.set('n', '<leader>h', show_documentation, opts)
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
			vim.keymap.set('n', 'gD', ':tab sp<CR><cmd>lua vim.lsp.buf.definition()<cr>', opts)
			vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
			vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
			vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
			vim.keymap.set('i', '<c-f>', vim.lsp.buf.signature_help, opts)
			vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
			-- vim.keymap.set({ 'n', 'x' }, '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
			vim.keymap.set('n', '<leader>aw', vim.lsp.buf.code_action, opts)
			vim.keymap.set('n', "<leader>,", vim.lsp.buf.code_action, opts)
			-- vim.keymap.set('x', '<leader>aw', vim.lsp.buf.range_code_action, opts)
			-- vim.keymap.set('x', "<leader>,", vim.lsp.buf.range_code_action, opts)
			vim.keymap.set('n', '<leader>t', ':Trouble<cr>', opts)
			vim.keymap.set('n', '<leader>-', vim.diagnostic.goto_prev, opts)
			vim.keymap.set('n', '<leader>=', vim.diagnostic.goto_next, opts)
		end
	})
end

vim.lsp.enable("clangd")
vim.lsp.enable("pyright")
vim.lsp.enable("yamlls")
vim.lsp.enable("emmet")
vim.lsp.enable("jsonls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("solargraph")
vim.lsp.enable("terraformls")
vim.lsp.enable("ts_ls")

return M
