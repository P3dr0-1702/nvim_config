return {
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- load before other plugins
    config = function()
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- disable italics
        },
      }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
}

