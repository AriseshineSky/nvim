local compileRun = function()
	vim.cmd("w")
	-- 检查文件类型
	local ft = vim.bo.filetype
	if ft == "markdown" then
		vim.cmd(":InstantMarkdownPreview")
	end
end

vim.keymap.set('n', 'r', compileRun, { silent = true })
