return {
	{ "nvie/vim-flake8" },
	{
		"dense-analysis/ale",
		config = function()
			-- 启用 ALE
			vim.g.ale_enabled = 1

			-- 使用 Autopep8 进行自动修正
			vim.g.ale_fixers = {
				python = { 'autopep8' },
			}

			vim.g.ale_linters = {
				python = { 'flake8' },
			}
			vim.g.ale_fix_on_save = 1
		end
	}
}
