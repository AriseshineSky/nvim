return {
  setup = function()
    -- solargraph (Ruby)
    vim.lsp.config("solargraph", {
      cmd = { "solargraph", "stdio" },
      settings = {
        solargraph = {
          formatting = true,
          diagnostics = true,
        },
      },
      filetypes = { "ruby" },
      root_dir = vim.lsp.config.util.root_pattern("Gemfile", ".git", ".ruby-version", "config/application.rb"),
      capabilities = {
        offsetEncoding = { "utf-16" }
      }
    })
    vim.lsp.enable("solargraph")
  end,
}
