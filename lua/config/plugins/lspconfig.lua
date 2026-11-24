local M = {}

local disable_semantic_tokens = true

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
		max_width = 80,
		max_height = 20,
	})
end

--- vim.lsp.buf.definition() and friends build their list from every location returned by every
--- client, without de-duplication. When a server reports the same target twice (Ruby LSP does
--- when its index holds two URIs for one file, e.g. one with a doubled slash - see
--- lsp/ruby-lsp.lua), `gd` shows two identical entries. Normalize filenames (so "a//b" and "a/b"
--- resolve to the same buffer) and drop duplicates.
--- @param items vim.quickfix.entry[]
--- @return vim.quickfix.entry[]
local function dedupe_locations(items)
	local seen, unique = {}, {}
	for _, item in ipairs(items) do
		local filename = item.filename and vim.fs.normalize(item.filename) or item.filename
		local key = string.format("%s:%d:%d", filename or "", item.lnum or 0, item.col or 0)
		if not seen[key] then
			seen[key] = true
			local copy = vim.deepcopy(item)
			copy.filename = filename
			unique[#unique + 1] = copy
		end
	end
	return unique
end

--- Mirrors the default behaviour: jump straight to the only remaining location, otherwise list them.
local function on_locations(list)
	local items = dedupe_locations(list.items or {})
	if #items == 1 then
		local item = items[1]
		local bufnr = item.bufnr or vim.fn.bufadd(item.filename)
		vim.cmd("normal! m'")
		vim.bo[bufnr].buflisted = true
		vim.api.nvim_win_set_buf(0, bufnr)
		vim.api.nvim_win_set_cursor(0, { item.lnum, math.max((item.col or 1) - 1, 0) })
		vim.cmd("normal! zv")
		return
	end
	vim.fn.setqflist({}, " ", { title = list.title or "LSP locations", items = items })
	vim.cmd("botright copen")
end

--- References always stay a list, they are just de-duplicated.
local function on_references(list)
	local items = dedupe_locations(list.items or {})
	vim.fn.setqflist({}, " ", { title = list.title or "LSP references", items = items })
	vim.cmd("botright copen")
end

local function configure_keybinds()
	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "LSP actions",
		callback = function(event)
			local opts = { buffer = event.buf, noremap = true, nowait = true }

			vim.keymap.set("n", "gd", function()
				vim.lsp.buf.definition({ on_list = on_locations })
			end, opts)
			vim.keymap.set("n", "gD", function()
				vim.cmd.tabnew()
				vim.lsp.buf.definition({ on_list = on_locations })
			end, opts)
			vim.keymap.set("n", "<leader>h", show_documentation, opts)
			vim.keymap.set("n", "gi", function()
				vim.lsp.buf.implementation({ on_list = on_locations })
			end, opts)
			vim.keymap.set("n", "go", function()
				vim.lsp.buf.type_definition({ on_list = on_locations })
			end, opts)
			vim.keymap.set("n", "gr", function()
				vim.lsp.buf.references(nil, { on_list = on_references })
			end, opts)
			-- 插入模式签名帮助改由 blink.cmp 处理（只显示参数行，不含长文档）
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			vim.keymap.set("n", "<leader>aw", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "<leader>,", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "<leader>t", ":Trouble<cr>", opts)
			vim.keymap.set("n", "<leader>-", function()
				vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
			end, opts)
			vim.keymap.set("n", "<leader>=", function()
				vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
			end, opts)
		end,
	})
end

--- Ruby LSP prints normal progress to stderr; Nvim always logs RPC stderr as [ERROR].
--- See :h vim.lsp.log (note about "stderr").
local function is_benign_ruby_lsp_stderr(...)
	local parts = {}
	for i = 1, select("#", ...) do
		parts[#parts + 1] = tostring(select(i, ...) or "")
	end
	local blob = table.concat(parts, "\n")
	if not (blob:find("stderr", 1, true) and blob:find("Ruby LSP", 1, true)) then
		return false
	end
	if blob:find("Error", 1, true) or blob:find("error:", 1, true) or blob:find("failed", 1, true) then
		return false
	end
	return true
end

local function configure_lsp()
	vim.lsp.log.set_level(vim.log.levels.WARN)

	local log_levels = vim.log.levels
	local log_date_format = "%F %H:%M:%S"
	vim.lsp.log.set_format_func(function(level, ...)
		if level == "ERROR" and is_benign_ruby_lsp_stderr(...) then
			return nil
		end
		if log_levels[level] < vim.lsp.log.get_level() then
			return nil
		end
		local info = debug.getinfo(2, "Sl")
		local header = string.format(
			"[%s][%s] %s:%s",
			level,
			os.date(log_date_format),
			info.short_src,
			info.currentline
		)
		local parts = { header }
		for i = 1, select("#", ...) do
			local arg = select(i, ...)
			table.insert(parts, arg == nil and "nil" or vim.inspect(arg, { newline = " ", indent = "" }))
		end
		return table.concat(parts, "\t") .. "\n"
	end)

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
	-- 保存时格式化必须异步。vim.lsp.buf.format({ async = false }) 内部是
	-- request_sync(..., 1000)，只要格式化服务器慢（实测 235KB 的 JSON 用
	-- jsonls 格式化要 ~600ms，慢服务器会直接撞 1000ms 超时），整个
	-- BufWritePre 被阻塞，保存体感就是“卡 1 秒”。
	-- 这里改为异步请求，格式化完成后再静默写回一次。
	local formatting_bufs = {}
	-- 服务器一直不回应时，别让守卫永久卡住这个 buffer
	local function reset_formatting_guard(bufnr, delay)
		local timer = vim.uv.new_timer()
		timer:start(delay, 0, vim.schedule_wrap(function()
			timer:stop()
			timer:close()
			formatting_bufs[bufnr] = nil
		end))
	end

	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*",
		callback = function(args)
			local bufnr = args.buf
			if not format_on_save_filetypes[vim.bo[bufnr].filetype] then
				return
			end
			if formatting_bufs[bufnr] then
				return
			end

			local clients = vim.lsp.get_clients({
				bufnr = bufnr,
				method = "textDocument/formatting",
			})
			clients = vim.tbl_filter(function(client)
				return client.name ~= "ts_ls"
			end, clients)
			if #clients == 0 then
				return
			end

			local win = vim.fn.bufwinid(bufnr)
			local cursor = win ~= -1 and vim.api.nvim_win_get_cursor(win) or nil
			formatting_bufs[bufnr] = true
			reset_formatting_guard(bufnr, 10000)

			local pending = #clients
			local function finish()
				pending = pending - 1
				if pending > 0 then
					return
				end
				if not vim.api.nvim_buf_is_valid(bufnr) then
					formatting_bufs[bufnr] = nil
					return
				end
				if cursor and vim.api.nvim_win_is_valid(win) then
					pcall(vim.api.nvim_win_set_cursor, win, cursor)
				end
				-- 格式化结果只在缓冲区里，需要再落盘一次。保持守卫为 true，
				-- 避免这次写入再次进入本回调造成死循环。
				if vim.bo[bufnr].modified and vim.bo[bufnr].buftype == "" then
					vim.api.nvim_buf_call(bufnr, function()
						vim.cmd("silent write")
					end)
				end
				formatting_bufs[bufnr] = nil
			end

			for _, client in ipairs(clients) do
				client:request("textDocument/formatting", vim.lsp.util.make_formatting_params(), function(err, result)
					if not err and result and vim.api.nvim_buf_is_valid(bufnr) then
						vim.lsp.util.apply_text_edits(result, bufnr, client.offset_encoding)
					end
					vim.schedule(finish)
				end, bufnr)
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
