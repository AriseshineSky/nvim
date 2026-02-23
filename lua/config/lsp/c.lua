return {
  setup = function()
    vim.lsp.config("clangd", {})
    vim.lsp.enable("clangd")
  end,
}
