-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Minimal options
vim.opt.termguicolors = true
vim.opt.updatetime = 100 -- Faster completion
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- Better completion experience
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.hidden = true -- Allow switching buffers without saving
vim.opt.mouse = "a" -- Enable mouse support
