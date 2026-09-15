-- lua/config/plugins/ts_ls.lua
return {
  cmd = { "typescript-language-server", "--stdio" }, -- make sure this matches your installed binary
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
}
