-- lua/config/plugins/emmet.lua
return {
  cmd = { "emmet-language-server", "--stdio" }, -- ensure this matches your server binary
  filetypes = {
    "css", "eruby", "html", "javascript",
    "javascriptreact", "less", "sass",
    "scss", "pug", "typescriptreact"
  },
  init_options = {
    includeLanguages = {},
    excludeLanguages = {},
    extensionsPath = {},
    preferences = {},
    showAbbreviationSuggestions = true,
    showExpandedAbbreviation = "always",
    showSuggestionsAsSnippets = false,
    syntaxProfiles = {},
    variables = {},
  },
}
