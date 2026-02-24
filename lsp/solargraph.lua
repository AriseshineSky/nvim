return {
  cmd = { "solargraph", "stdio" },
  filetypes = { "ruby" },
  root_markers = { "Gemfile", ".git", ".ruby-version", "config/application.rb" },
  settings = {
    solargraph = {
      formatting = true,
      diagnostics = true,
    },
  },
  capabilities = {
    offsetEncoding = { "utf-16" },
  },
}
