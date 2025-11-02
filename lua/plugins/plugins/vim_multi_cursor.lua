return {
  {
    'mg979/vim-visual-multi',
    branch = 'master',
    event = 'VimEnter',
    config = function()
      -- Load centralized keymaps for Visual Multi
      local km = require("keymaps").visual_multi
      vim.g.VM_maps = km.maps
      vim.g.VM_highlight_matches = km.highlight or 'visual'
    end,
  },
}
