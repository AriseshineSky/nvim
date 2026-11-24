return {
	{
		"mfussenegger/nvim-dap",
		lazy = false,
		dependencies = {
			{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- 调试器用 lldb-dap（随 llvm/clang 一起装好，见 /usr/bin/lldb-dap），
			-- 不需要再下载 codelldb。想换适配器只改下面这一段。
			dap.adapters.lldb = {
				type = "executable",
				command = "lldb-dap",
				name = "lldb-dap",
			}

			-- 猜可执行文件：当前文件同目录同名 → ./build/<name> → 让用户填。
			-- 用 CMake + CMAKE_EXPORT_COMPILE_COMMANDS 时产物一般在 build/ 里。
			local function resolve_program()
				local file = vim.api.nvim_buf_get_name(0)
				if file == "" then
					return vim.fn.input("Path to executable: ", vim.uv.cwd() .. "/", "file")
				end
				local dir = vim.fs.dirname(file)
				local stem = vim.fn.fnamemodify(file, ":t:r")
				local candidates = {
					dir .. "/" .. stem,
					dir .. "/build/" .. stem,
					vim.uv.cwd() .. "/build/" .. stem,
					vim.uv.cwd() .. "/" .. stem,
				}
				for _, path in ipairs(candidates) do
					if vim.fn.executable(path) == 1 then
						return path
					end
				end
				return vim.fn.input("Path to executable: ", dir .. "/", "file")
			end

			local c_configs = {
				{
					name = "Launch (lldb-dap)",
					type = "lldb",
					request = "launch",
					-- program 是函数时，每次启动都会重新求值
					program = resolve_program,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
					runInTerminal = false,
					-- 程序要读 stdin 时（scanf/getchar），改成：
					-- console = "integratedTerminal",
				},
			}
			dap.configurations.c = c_configs
			dap.configurations.cpp = c_configs

			-- 断点/当前行标注在代码旁边
			require("nvim-dap-virtual-text").setup({
				enabled = true,
				virt_text_pos = "eol",
				only_first_line = true,
			})

			dapui.setup({
				icons = { collapsed = "", expanded = "", current_frame = "" },
				controls = { enabled = true, element = "repl" },
				layouts = {
					{
						elements = { "scopes", "breakpoints", "stacks", "watches" },
						size = 40,
						position = "left",
					},
					{
						elements = { "repl", "console" },
						size = 12,
						position = "bottom",
					},
				},
				render = { max_value_lines = 100 },
			})

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			-- F 系列快捷键在 Colemak 布局下同样可用，不会和 hjkl 替换冲突。
			local opts = { noremap = true, silent = true }
			vim.keymap.set("n", "<F5>", function()
				dap.continue()
			end, vim.tbl_extend("force", opts, { desc = "DAP: 启动/继续" }))
			vim.keymap.set("n", "<F9>", function()
				dap.toggle_breakpoint()
			end, vim.tbl_extend("force", opts, { desc = "DAP: 切换断点" }))
			vim.keymap.set("n", "<F10>", function()
				dap.step_over()
			end, vim.tbl_extend("force", opts, { desc = "DAP: 单步跳过" }))
			vim.keymap.set("n", "<F11>", function()
				dap.step_into()
			end, vim.tbl_extend("force", opts, { desc = "DAP: 单步进入" }))
			vim.keymap.set("n", "<S-F11>", function()
				dap.step_out()
			end, vim.tbl_extend("force", opts, { desc = "DAP: 单步跳出" }))
			-- 同上，Colemak 下也留一套字母映射（<leader>D 前缀，避开 telescope 的 <leader>d）
			vim.keymap.set("n", "<leader>Dc", function()
				dap.continue()
			end, vim.tbl_extend("force", opts, { desc = "DAP continue" }))
			vim.keymap.set("n", "<leader>Db", function()
				dap.toggle_breakpoint()
			end, vim.tbl_extend("force", opts, { desc = "DAP toggle breakpoint" }))
			vim.keymap.set("n", "<leader>Dn", function()
				dap.step_over()
			end, vim.tbl_extend("force", opts, { desc = "DAP step over" }))
			vim.keymap.set("n", "<leader>Di", function()
				dap.step_into()
			end, vim.tbl_extend("force", opts, { desc = "DAP step into" }))
			vim.keymap.set("n", "<leader>Do", function()
				dap.step_out()
			end, vim.tbl_extend("force", opts, { desc = "DAP step out" }))
			vim.keymap.set("n", "<leader>Du", function()
				dapui.toggle()
			end, vim.tbl_extend("force", opts, { desc = "DAP toggle UI" }))
			vim.keymap.set("n", "<leader>Dr", function()
				dap.repl.toggle()
			end, vim.tbl_extend("force", opts, { desc = "DAP REPL" }))
			vim.keymap.set("n", "<leader>Dt", function()
				dap.terminate()
			end, vim.tbl_extend("force", opts, { desc = "DAP terminate" }))
			vim.keymap.set("n", "<leader>DB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, vim.tbl_extend("force", opts, { desc = "DAP conditional breakpoint" }))
			vim.keymap.set("n", "<leader>DL", function()
				dap.list_breakpoints()
				vim.cmd("botright copen")
			end, vim.tbl_extend("force", opts, { desc = "DAP list breakpoints" }))
			vim.keymap.set("n", "<leader>De", function()
				dapui.eval()
			end, vim.tbl_extend("force", opts, { desc = "DAP eval expression" }))
			vim.keymap.set("n", "<leader>DE", function()
				dapui.eval(vim.fn.expand("<cexpr>"))
			end, vim.tbl_extend("force", opts, { desc = "DAP eval word under cursor" }))
			vim.keymap.set("n", "<leader>DX", function()
				dap.clear_breakpoints()
				require("notify")("DAP: breakpoints cleared", "info")
			end, vim.tbl_extend("force", opts, { desc = "DAP clear breakpoints" }))
		end,
	},
}