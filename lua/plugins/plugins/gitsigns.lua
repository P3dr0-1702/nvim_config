-- lua/plugins/plugins/gitsigns.lua

return {
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
      },
      
      -- Keymaps
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        -- Use ']c' and '[c' to navigate between hunks
        -- This is a standard Vim convention
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true, desc = 'Go to next git hunk'})

        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true, desc = 'Go to previous git hunk'})

        -- Actions
        map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>', {desc = 'Stage git hunk'})
        map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>', {desc = 'Reset git hunk'})
        map('n', '<leader>hS', gs.stage_buffer, {desc = 'Stage entire buffer'})
        map('n', '<leader>hu', gs.undo_stage_hunk, {desc = 'Undo last staged hunk'})
        map('n', '<leader>hR', gs.reset_buffer, {desc = 'Reset entire buffer'})
        map('n', '<leader>hp', gs.preview_hunk, {desc = 'Preview git hunk'})
        map('n', '<leader>hb', function() gs.blame_line{full=true} end, {desc = 'Blame line'})
        
        -- Text object
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {desc = 'Select git hunk'})
      end
    },
  },
}
