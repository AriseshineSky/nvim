return {
    cmd = { "terraform-ls", "serve" },  -- terraform-ls binary
    filetypes = { "terraform", "tf" }, -- automatically attach to .tf files
    root_markers = { ".git", ".terraform" }, -- project root detection
    settings = {},  -- you can add terraform-specific settings if needed
}
