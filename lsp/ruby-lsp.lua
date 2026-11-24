-- Ruby LSP picks the files it indexes from two places: the workspace root sent by the editor and
-- the server process' *working directory* (`Dir.pwd`, used by RubyIndexer::Configuration to list
-- top level directories). Nvim spawns language servers with nvim's own cwd, so if nvim was
-- started from a subdirectory (or the cwd changes only after the client starts), Ruby LSP ends
-- up globbing "#{workspace}/{}/**/*.rb" - the empty brace expands to "" and every project file is
-- indexed as "file:///…/project//app/foo.rb" instead of "file:///…/project/app/foo.rb".
-- The open buffer is indexed separately under its real URI, so definition/implementation/
-- typeDefinition return the same target twice and `gd` shows two identical quickfix entries.
-- Fix: spawn the server ourselves so its cwd is always the resolved root_dir.
local function start_ruby_lsp(dispatchers, config)
	-- Without a project root (single file mode) never fall back to nvim's cwd: that could be a
	-- parent directory holding dozens of unrelated projects, which Ruby LSP would index. Scope the
	-- index to the file's own directory instead.
	local cwd = config.root_dir
	if not cwd then
		local name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
		local dir = name ~= "" and vim.fs.dirname(name) or nil
		cwd = dir and vim.fs.normalize(dir) or vim.fn.getcwd()
	end

	return vim.lsp.rpc.start({ "rbenv", "exec", "ruby-lsp" }, dispatchers, {
		cwd = cwd,
		env = config.cmd_env,
		detached = config.detached,
	})
end

return {
	filetypes = { "ruby" },
	cmd = start_ruby_lsp,
	-- Only treat real Ruby projects as a workspace root. `.ruby-version` alone is not enough: it is
	-- often present in a parent folder that merely groups several projects (e.g. ~/src), which made
	-- nvim start a second ruby-lsp that indexed the whole parent tree. Stray files now start in
	-- single file mode instead.
	root_markers = { "Gemfile", "config/application.rb" },
	init_options = {
		formatter = "rubocop",
		linters = { "rubocop" },
		addonSettings = {
			["Ruby LSP Rails"] = {
				enablePendingMigrationsPrompt = false,
			},
			["Ruby LSP RSpec"] = {},
		},
		-- 不要给 enabledFeatures 传字符串数组。Ruby LSP 会把数组当成「功能白名单」：
		-- 未出现的键（如 definition、completion）全部为 false → 没有 definitionProvider。
		-- Rails / RSpec 用 Gemfile 里的 ruby-lsp-rails、ruby-lsp-rspec 等 addon + addonSettings，不在这里开。
	},
}
