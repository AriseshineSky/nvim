return {
  setup = function()
    -- terraform
    vim.lsp.config("terraformls", {})
    vim.lsp.enable("terraformls")
  end,
}
