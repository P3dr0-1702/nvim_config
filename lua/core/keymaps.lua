-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local funcs = require("core.funcs")
-- Fixed commands to properly handle :q and :wq
vim.api.nvim_create_user_command('Q', function() funcs.safe_bdelete() end, {})
vim.api.nvim_create_user_command('WQ', function()  funcs.save_and_close() end, {})
vim.api.nvim_create_user_command('B', function() funcs.safe_bdelete() end, {})
vim.api.nvim_create_user_command('WB', function() funcs.save_and_close() end, {})
vim.api.nvim_create_user_command('BA', function() funcs.save_all_and_bdelete_all() end, {})

-- -- Override common commands with command-line abbreviations
-- vim.cmd [[
--   cnoreabbrev <expr> q getcmdtype() == ':' && getcmdline() == 'q' ? 'Q' : 'q'
--   cnoreabbrev <expr> wq getcmdtype() == ':' && getcmdline() == 'wq' ? 'WQ' : 'wq'
-- ]]


vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if package.loaded["toggleterm"] then
      vim.keymap.set(
        "n",
        "<leader><leader>",
        "<cmd>ToggleTerm<CR>",
        { desc = "Toggle terminal", noremap = true, silent = true }
      )
    end
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if package.loaded["telescope.builtin"] then
      local builtin = require("telescope.builtin")
      -- Buffer search
      vim.keymap.set("n", "<leader>p", builtin.buffers, { desc = "Find existing buffers" })

      -- Keep other telescope mappings here
      -- vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
      -- vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      -- vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      -- vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      -- vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      -- vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
    end
  end,
})

--safe_bdelete
vim.keymap.set('n', "<leader>cc", ":B<CR>")
vim.keymap.set('n', "<leader>ca", ":BA<CR>")

-- NvimTree toggle
vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>")

-- 42 formatter
vim.keymap.set("n", "<leader>i", function()
  vim.cmd("silent! write")
  vim.cmd("!c_formatter_42 %")
  vim.cmd("edit!")
end, { noremap = true, silent = true, desc = "Format with 42 formatter" })

-- Search
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>w", "<cmd>Telescope live_grep<CR>")

-- Terminal mode exit
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Move focus to the upper window" })
--cut command
vim.keymap.set({ "n", "v" }, "<leader>x", '"+d', { desc = "Cut to clipboard" })
-- Buffer navigation
vim.keymap.set("n", "<C-l>", "<cmd>BufferLineCycleNext<CR>", { noremap = true, desc = "Next buffer" })
vim.keymap.set("n", "<C-h>", "<cmd>BufferLineCyclePrev<CR>", { noremap = true, desc = "Previous buffer" })

--Insert empty line without exiting 
vim.keymap.set('n', '<CR>', 'm`o<Esc>``')
vim.keymap.set('n', '<S-CR>', 'm`O<Esc>``')
-- Make delete operations not affect the yank register
vim.keymap.set("n", "dd", '"_dd', { noremap = true, desc = "Delete line without yanking" })
vim.keymap.set("n", "d", '"_d', { noremap = true, desc = "Delete without yanking" })
vim.keymap.set("v", "d", '"_d', { noremap = true, desc = "Delete without yanking" })
vim.keymap.set("n", "D", '"_D', { noremap = true, desc = "Delete to end of line without yanking" })
vim.keymap.set("n", "x", '"_x', { noremap = true, desc = "Delete character without yanking" })
vim.keymap.set("v", "x", '"_x', { noremap = true, desc = "Delete character without yanking" })
vim.keymap.set("n", "c", '"_c', { noremap = true, desc = "Change without yanking" })
vim.keymap.set("v", "c", '"_c', { noremap = true, desc = "Change without yanking" })
vim.keymap.set("n", "C", '"_C', { noremap = true, desc = "Change to end of line without yanking" })

vim.keymap.set("n", "<leader>g", vim.lsp.buf.definition, {noremap = true, silent = true})
vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true, desc = "Show hover information" })

vim.api.nvim_create_user_command('WQA', function()
  vim.cmd('wa')
  vim.cmd('qa')
end, { desc = "Write all then quit all" })

-- Split horizontally (down)
vim.api.nvim_set_keymap('n', '<leader>sh', ':split<CR>', { noremap = true, silent = true })
-- Split vertically (right)
vim.api.nvim_set_keymap('n', '<leader>sv', ':vsplit<CR>', { noremap = true, silent = true })

-- Resize windows (Alt + Arrow, inverted left/right)
vim.keymap.set("n", "<A-Left>",  ":vertical resize +5<CR>", { noremap = true, silent = true, desc = "Increase window width" })
vim.keymap.set("n", "<A-Right>", ":vertical resize -5<CR>", { noremap = true, silent = true, desc = "Decrease window width" })
vim.keymap.set("n", "<A-Up>",    ":resize -2<CR>",         { noremap = true, silent = true, desc = "Decrease window height" })
vim.keymap.set("n", "<A-Down>",  ":resize +2<CR>",         { noremap = true, silent = true, desc = "Increase window height" })

local M = {}

M.visual_multi = {
  maps = {
    ["Find Under"] = "<C-d>", -- select next occurrence
    ["Find Subword Under"] = "<C-d>", -- select next subword
    ["Select All"] = "<C-a>", -- select all occurrences
    ["Add Cursor Up"] = "<C-Up>", -- add cursor above
    ["Add Cursor Down"] = "<C-Down>", -- add cursor below
  },
  highlight = "visual", -- optional, default is 'visual'
}
return M
