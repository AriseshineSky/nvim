	return {
	filetypes = { "ruby" },
	cmd = { "rbenv", "exec", "ruby-lsp" },
	root_markers = { "Gemfile", ".git", ".ruby-version", "config/application.rb" },
	init_options = {
		formatter = "standard",
		linters = { "standard" },
		addonSettings = {
			["Ruby LSP Rails"] = {
				enablePendingMigrationsPrompt = false
			},
			["Ruby LSP RSpec"] = {},
		},
		-- 不要给 enabledFeatures 传字符串数组。Ruby LSP 会把数组当成「功能白名单」：
		-- 未出现的键（如 definition、completion）全部为 false → 没有 definitionProvider。
		-- Rails / RSpec 用 Gemfile 里的 ruby-lsp-rails、ruby-lsp-rspec 等 addon + addonSettings，不在这里开。
	},
}
