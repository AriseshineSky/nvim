-- Markview is declared here so it depends on nvim-treesitter (see treesitter.lua).
-- Do not add a second `nvim-treesitter` spec; lazy.nvim merges would duplicate the plugin.
return {
	{
		"OXY2DEV/markview.nvim",
		lazy = false,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
}
