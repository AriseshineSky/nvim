return {
  setup = function()
    -- ruff (Python linter)
    vim.lsp.config("ruff", {
      cmd = { vim.g.python3_host_prog, "-m", "ruff", "lsp" },
      root_dir = vim.lsp.config.util.root_pattern(".git", "pyproject.toml"),
    })
    vim.lsp.enable("ruff")
  end,
}
