return {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html", "eruby" },
  root_markers = { ".git", "package.json" },
  init_options = {
    provideFormatter = true,
  },
  settings = {
    html = {
      format = {
        tabSize = 2,
        insertSpaces = true,
      },
    },
  },
}
