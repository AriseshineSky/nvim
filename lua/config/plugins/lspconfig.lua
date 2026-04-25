local M = {}

local disable_semantic_tokens = true

local signature_help_opts = {
	focusable = false,
	border = "rounded",
	zindex = 60,
}

local function lsp_signature_help()
	vim.lsp.buf.signature_help(signature_help_opts)
end

local function configure_doc_and_signature()
	local group = vim.api.nvim_create_augroup("lsp_diagnostics_hold", { clear = true })
	vim.api.nvim_create_autocmd("CursorHold", {
		pattern = "*",
		group = group,
		callback = function()
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
		end,
	})
end

local function show_documentation()
	vim.lsp.buf.hover({
		focusable = false,
		border = "rounded",
	})
end

local function configure_keybinds()
	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "LSP actions",
		callback = function(event)
			local opts = { buffer = event.buf, noremap = true, nowait = true }

			vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			vim.keymap.set("n", "gD", function()
				vim.cmd.tabnew()
				vim.lsp.buf.definition()
			end, opts)
			vim.keymap.set("n", "<leader>h", show_documentation, opts)
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
			vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
			vim.keymap.set("i", "<c-f>", lsp_signature_help, opts)
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			vim.keymap.set("n", "<leader>aw", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "<leader>,", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "<leader>t", ":Trouble<cr>", opts)
			vim.keymap.set("n", "<leader>-", function()
				vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
			end, opts)
			vim.keymap.set("n", "<leader>=", function()
				vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
			end, opts)
		end,
	})
end

local function configure_lsp()
	vim.lsp.log.set_level(vim.log.levels.WARN)

	vim.diagnostic.config({
		severity_sort = true,
		underline = true,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "✘",
				[vim.diagnostic.severity.WARN] = "▲",
				[vim.diagnostic.severity.HINT] = "⚑",
				[vim.diagnostic.severity.INFO] = "»",
			},
		},
		virtual_text = false,
		update_in_insert = false,
		float = true,
	})

	configure_doc_and_signature()
	configure_keybinds()

	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "LSP client capability tweaks",
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if not client then
				return
			end

			if client.name == "ts_ls" and vim.bo[event.buf].filetype ~= "javascript" then
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
			end

			if client.name == "ts_ls" then
				client.server_capabilities.semanticTokensProvider = nil
			end

			if disable_semantic_tokens then
				client.server_capabilities.semanticTokensProvider = nil
			end
		end,
	})

	local format_on_save_filetypes = {
		json = true,
		lua = true,
		html = true,
		css = true,
		javascript = true,
		typescript = true,
		typescriptreact = true,
		toml = true,
	}
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*",
		callback = function()
			if format_on_save_filetypes[vim.bo.filetype] then
				local lineno = vim.api.nvim_win_get_cursor(0)
				vim.lsp.buf.format({
					async = false,
					filter = function(client)
						return client.name ~= "ts_ls"
					end,
				})
				pcall(vim.api.nvim_win_set_cursor, 0, lineno)
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = { "*.hcl" },
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local filename = vim.api.nvim_buf_get_name(bufnr)
			vim.system({ "packer", "fmt", filename }, {}, function()
				vim.schedule(function()
					vim.cmd("edit!")
				end)
			end)
		end,
	})

	local servers = {
		"clangd",
		"pyright",
		"yamlls",
		"emmet",
		"jsonls",
		"lua_ls",
		"ruby-lsp",
		"ts_ls",
	}
	for _, server in ipairs(servers) do
		local ok, config = pcall(require, "lsp." .. server)
		if ok and type(config) == "table" then
			vim.lsp.config(server, config)
		else
			vim.lsp.config(server, {})
		end
		vim.lsp.enable(server)
	end
end

configure_lsp()

M.config = {
	{
		"weilbith/nvim-code-action-menu",
		cmd = "CodeActionMenu",
	},
	{
		"folke/trouble.nvim",
		opts = {
			use_diagnostic_signs = true,
			action_keys = {
				close = "<esc>",
				previous = "u",
				next = "e",
			},
		},
	},
	{
		"j-hui/fidget.nvim",
		tag = "legacy",
		opts = {},
		config = function(_, opts)
			require("fidget").setup(opts)
		end,
	},
	{ "folke/lazydev.nvim",  ft = "lua", opts = {} },
	{ "airblade/vim-rooter" },
	{ "b0o/schemastore.nvim" },
}

return M
