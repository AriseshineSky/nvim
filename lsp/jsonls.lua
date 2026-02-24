return {
  cmd = { "vscode-json-languageserver", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
  settings = {
    json = {
      schemas = {},
      validate = true,
    },
  },
}
