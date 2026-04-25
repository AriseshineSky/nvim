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
		enabledFeatures = {
			"rails",
			"rspec"
		},
	}
}
