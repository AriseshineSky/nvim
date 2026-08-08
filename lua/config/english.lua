-- 英语学习模块（自包含，可随时删除本文件 + init.lua 里的一行 require）
-- 依赖：translate-shell (`trans`)，可选：telescope
-- vault 路径：修改这里即可
local VAULT = vim.fn.expand("~/src/english-learning")

local M = {}

-- 在浮动窗口里显示命令输出
local function float_show(title, lines)
	local width = 0
	for _, l in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(l))
	end
	width = math.min(math.max(width + 2, 30), math.floor(vim.o.columns * 0.8))
	local height = math.min(#lines + 1, math.floor(vim.o.lines * 0.7))

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "markdown"

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "cursor",
		row = 1,
		col = 1,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " " .. title .. " ",
		title_pos = "center",
	})
	vim.wo[win].wrap = true
	-- q 或 Esc 关闭
	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, "<cmd>close<CR>", { buffer = buf, nowait = true, silent = true })
	end
end

-- 运行 trans 并弹窗展示
local function run_trans(args, title)
	if vim.fn.executable("trans") == 0 then
		vim.notify("未找到 translate-shell (trans)，请先安装：yay -S translate-shell", vim.log.levels.ERROR)
		return
	end
	local cmd = { "trans", "-no-ansi" }
	vim.list_extend(cmd, args)
	local out = vim.fn.systemlist(cmd)
	-- 兜底：即便 -no-ansi 失效，也把残留的转义码去掉
	for i, line in ipairs(out) do
		out[i] = line:gsub("\27%[[0-9;]*m", ""):gsub("%[[0-9;]+m", "")
	end
	if vim.v.shell_error ~= 0 or #out == 0 then
		vim.notify("翻译失败：" .. table.concat(out, " "), vim.log.levels.WARN)
		return
	end
	float_show(title, out)
end

-- 光标下的词：英文释义 + 中文
function M.lookup_word()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		return
	end
	run_trans({ "-d", "en:zh", word }, "词典: " .. word)
end

-- 可视选区：整句翻译成中文
local function get_visual_selection()
	local _, ls, cs = unpack(vim.fn.getpos("'<"))
	local _, le, ce = unpack(vim.fn.getpos("'>"))
	local lines = vim.fn.getline(ls, le)
	if #lines == 0 then
		return ""
	end
	lines[#lines] = string.sub(lines[#lines], 1, ce)
	lines[1] = string.sub(lines[1], cs)
	return table.concat(lines, " ")
end

function M.translate_selection()
	local text = get_visual_selection()
	if text == "" then
		return
	end
	run_trans({ "-b", "en:zh", text }, "翻译")
end

-- 打开学习库（优先用 telescope，否则用内置文件浏览）
function M.open_vault()
	local ok, builtin = pcall(require, "telescope.builtin")
	if ok then
		builtin.find_files({ cwd = VAULT, prompt_title = "English Vault" })
	else
		vim.cmd("edit " .. VAULT)
	end
end

-- 一键备份：commit + push
function M.save_vault()
	local msg = "study: " .. os.date("%Y-%m-%d")
	vim.notify("正在备份学习库…", vim.log.levels.INFO)
	vim.system(
		{ "sh", "-c", string.format("cd %q && git add -A && git commit -m %q && git push", VAULT, msg) },
		{ text = true },
		function(res)
			vim.schedule(function()
				if res.code == 0 then
					vim.notify("已推送到 GitHub ✓", vim.log.levels.INFO)
				else
					local err = (res.stderr or "") .. (res.stdout or "")
					if err:match("nothing to commit") then
						vim.notify("没有新的改动可提交", vim.log.levels.INFO)
					else
						vim.notify("备份失败：" .. err, vim.log.levels.ERROR)
					end
				end
			end)
		end
	)
end

-- 新建一篇精读笔记（从模板生成并打开）
function M.new_reading_note()
	local title = vim.fn.input("标题: ")
	if title == "" then
		return
	end
	local url = vim.fn.input("来源URL: ")
	local slug = title:lower():gsub("[^%w]+", "-"):gsub("^-+", ""):gsub("-+$", "")
	local path = string.format("%s/reading/%s.md", VAULT, slug)
	local date = os.date("%Y-%m-%d")
	local tpl = {
		"# 精读：" .. title,
		"",
		"- 来源：" .. url,
		"- 开始日期：" .. date,
		"- 状态：进行中",
		"",
		"> 学法提醒：不列孤立单词，只记「整句 + 上下文」，重点是能套用的句型。",
		"",
		"## 一句话主旨",
		"",
		"",
		"## 值得偷师的整句表达（带上下文）",
		"",
		"### 1. ",
		"> ",
		"",
		"我的仿写：",
		"",
		"## 内容笔记（中文抓要点）",
		"",
		"- ",
		"",
		"## 理解自测题",
		"",
		"1. ",
		"",
		"## 复述（输出，写 5-8 句英文）",
		"",
		"",
	}
	vim.fn.mkdir(VAULT .. "/reading", "p")
	local fd = io.open(path, "w")
	if not fd then
		vim.notify("无法创建文件：" .. path, vim.log.levels.ERROR)
		return
	end
	fd:write(table.concat(tpl, "\n"))
	fd:close()
	vim.cmd("edit " .. vim.fn.fnameescape(path))
	vim.notify("已创建：" .. path, vim.log.levels.INFO)
end

-- 在光标处插入一个「句型」块
function M.insert_pattern()
	local lines = {
		"### <句型>",
		"> <带上下文的原句>",
		"",
		"我的仿写：",
		"",
	}
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row, row, false, lines)
	vim.api.nvim_win_set_cursor(0, { row + 1, 4 })
	vim.notify("已插入句型块", vim.log.levels.INFO)
end

local function map(lhs, fn, desc, mode)
	vim.keymap.set(mode or "n", lhs, fn, { desc = desc, silent = true })
end

map("<leader>ed", M.lookup_word, "English: 查词（光标下）")
map("<leader>et", M.translate_selection, "English: 翻译选区", "v")
map("<leader>ef", M.open_vault, "English: 打开学习库")
map("<leader>eg", M.save_vault, "English: 备份到 GitHub")
map("<leader>en", M.new_reading_note, "English: 新建精读笔记")
map("<leader>ep", M.insert_pattern, "English: 插入句型块")

vim.api.nvim_create_user_command("EnglishSave", M.save_vault, {})
vim.api.nvim_create_user_command("EnglishVault", M.open_vault, {})
vim.api.nvim_create_user_command("EnglishNote", M.new_reading_note, {})

return M
