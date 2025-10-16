-- init.lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set completeopt globally
vim.opt.completeopt = "menu,menuone,noselect"

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  }
end
vim.opt.rtp:prepend(lazypath)

-- Load modular configs
require("funcs")    -- toggle_detach, safe_bdelete, setup_function_line_count
require("keymaps")  -- keymaps only

-- Load all plugins via your plugins/init.lua
require("lazy").setup(require("plugins"))

-- Load LSP config after plugins
require("lsp")      -- LSP setup as regular module
