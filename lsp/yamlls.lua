-- lua/config/plugins/yamlls.lua
return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },
  root_markers = { ".git", ".yamlls.yml" },
  settings = {
    redhat = {
      telemetry = { enabled = false },
    },
    yaml = {
      schemaStore = {
        enable = false,
        url = "",
      },
      validate = false,
      customTags = {
        "!fn", "!And", "!If", "!Not", "!Equals", "!Or",
        "!FindInMap sequence", "!Base64", "!Cidr", "!Ref",
        "!Sub", "!GetAtt", "!GetAZs", "!ImportValue",
        "!Select", "!Split", "!Join sequence",
      }
    }
  }
}
