return {
  setup = function()
    vim.lsp.config("jsonls", {})
    vim.lsp.enable("jsonls")
  end,
}
