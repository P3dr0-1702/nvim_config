-- Leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Editor settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.shell = '/bin/zsh -i'
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', space = '·', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- Clipboard must be set after startup
vim.schedule(function()
    vim.o.clipboard = 'unnamedplus'
end)

-- Fonts
vim.g.have_nerd_font = true

-- Import functions from funcs.lua
local funcs = require("funcs")

-- === Plugin-Specific Keymaps (Centralized) === --

-- Auto-delete buffers when closing with :q or :wq
local funcs = require("funcs")

-- Fixed commands to properly handle :q and :wq
vim.api.nvim_create_user_command('Q', function() funcs.safe_bdelete() end, {})
vim.api.nvim_create_user_command('WQ', function()  funcs.save_and_close() end, {})

-- Override common commands with command-line abbreviations
vim.cmd [[
  cnoreabbrev <expr> q getcmdtype() == ':' && getcmdline() == 'q' ? 'Q' : 'q'
  cnoreabbrev <expr> wq getcmdtype() == ':' && getcmdline() == 'wq' ? 'WQ' : 'wq'
]]

-- Remove these duplicate abbreviations that could be causing conflicts
-- vim.cmd('cabbrev q Q')
-- vim.cmd('cabbrev wq WQ')

-- Toggle Terminal
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if package.loaded["toggleterm"] then
      vim.keymap.set('n', '<leader><leader>', '<cmd>ToggleTerm<CR>', 
        { desc = 'Toggle terminal', noremap = true, silent = true })
    end
  end
})

-- Telescope
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if package.loaded["telescope.builtin"] then
      local builtin = require('telescope.builtin')
      -- Buffer search
      vim.keymap.set('n', '<leader>p', builtin.buffers, { desc = 'Find existing buffers' })
      
      -- Keep other telescope mappings here
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    end
  end
})

-- NvimTree toggle
vim.keymap.set('n', '<C-b>', ':NvimTreeToggle<CR>')

-- Buffer detach/reattach
vim.keymap.set('n', '<leader>d', funcs.toggle_detach, { desc = 'Detach/Reattach buffer' })

-- 42 formatter
vim.keymap.set('n', '<leader>i', function()
    vim.cmd 'silent! write'
    vim.cmd '!c_formatter_42 %'
    vim.cmd 'edit!'
end, { noremap = true, silent = true, desc = 'Format with 42 formatter' })

-- Search
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Terminal mode exit
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation
vim.keymap.set('n', '<leader>h', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<leader>l', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<leader>j', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<leader>k', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Buffer navigation
vim.keymap.set('n', '<C-l>', ':BufferLineCycleNext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<C-h>', ':BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })

-- Make delete operations not affect the yank register
vim.keymap.set('n', 'dd', '"_dd', { noremap = true, desc = 'Delete line without yanking' })
vim.keymap.set('n', 'd', '"_d', { noremap = true, desc = 'Delete without yanking' })
vim.keymap.set('v', 'd', '"_d', { noremap = true, desc = 'Delete without yanking' })
vim.keymap.set('n', 'D', '"_D', { noremap = true, desc = 'Delete to end of line without yanking' })
vim.keymap.set('n', 'x', '"_x', { noremap = true, desc = 'Delete character without yanking' })
vim.keymap.set('v', 'x', '"_x', { noremap = true, desc = 'Delete character without yanking' })
vim.keymap.set('n', 'c', '"_c', { noremap = true, desc = 'Change without yanking' })
vim.keymap.set('v', 'c', '"_c', { noremap = true, desc = 'Change without yanking' })
vim.keymap.set('n', 'C', '"_C', { noremap = true, desc = 'Change to end of line without yanking' })
