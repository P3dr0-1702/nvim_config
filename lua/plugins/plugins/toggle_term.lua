return {
	{
		'akinsho/toggleterm.nvim',
		version = '*',
		config = function()
		require('toggleterm').setup {
			size = 15,
			open_mapping = [[<leader>t]],
			shade_terminals = true,
			direction = 'float',
			float_opts = { border = 'curved' },
			start_in_insert = true,
			shell = '/bin/zsh',
		}

		local opts = { buffer = 0 }
		vim.api.nvim_create_autocmd('TermOpen', {
			pattern = 'term://*',
			callback = function()
			vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
			vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], opts)
			vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], opts)
			vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], opts)
			vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], opts)
			end,
		})
		end,
	},
}
