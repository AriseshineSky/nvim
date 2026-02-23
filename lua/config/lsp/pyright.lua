return {
  setup = function()
    -- pyright
    vim.lsp.config("pyright", {
      root_dir = vim.lsp.config.util.root_pattern(".git", "pyproject.toml"),
    })
    vim.lsp.enable("pyright")
  end,
}
