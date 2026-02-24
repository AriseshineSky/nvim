require("neodev").setup({
    lspconfig = true, -- automatically integrates with lua_ls
    override = function()
        -- you can override settings here if needed
    end,
})

return {
    cmd = { "lua-language-server" },  -- make sure your lua_ls binary is correct
    filetypes = { "lua" },
    root_markers = { ".git" },
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim", "require" }, -- allow these globals
            },
            workspace = {
                checkThirdParty = false, -- disable prompt about third-party libraries
            },
            completion = {
                callSnippet = "Replace", -- behavior for function call snippets
            },
        },
    },
}
