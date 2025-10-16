return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'windwp/nvim-ts-autotag',               -- auto-close HTML/JSX tags
      'nvim-treesitter/nvim-treesitter-textobjects', -- motions & text objects
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'lua', 'c', 'cpp', 'python', 'javascript', 'typescript',
          'bash', 'json', 'yaml', 'html', 'css', 'markdown',
        },
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
          },
        },
      }
    end,
  },
}

