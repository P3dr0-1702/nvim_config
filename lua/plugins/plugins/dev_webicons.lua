return
{
	'nvim-tree/nvim-web-devicons',
	{
		'nvim-tree/nvim-tree.lua',
		config = function()
		require('nvim-tree').setup { view = { width = 24 } }
		end,
	}
}
