return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup {
        options = {
          numbers = 'none',
          diagnostics = 'nvim_lsp',
          separator_style = 'slant',
          show_buffer_close_icons = false,
          show_close_icon = false,
          -- Add left margin (offset)
          offsets = {
            {
              filetype = "",
              text = "",
              text_align = "left",
              separator = false,
              padding = 1,
              highlight = "Normal",
              -- Adjust this value to increase/decrease the left margin size
              length = 2
            }
          },
			style = {
          -- Adjust this value to change the height of the tabs
          	height = 50, -- taller tabs (default is smaller)
        	},
        },
        -- Control the height and other style aspects
        highlights = {
          fill = {
            -- Adjust the background of the bufferline bar
            fg = '#ffffff',
            bg = '#000000',
          },
          buffer_selected = {
            bold = true,
            italic = false,
          },
          -- You can add custom height by adjusting the bottom padding
          -- in the highlights section
        }
      }
    end,
  },
}
