-- init.lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  }
end
vim.opt.rtp:prepend(lazypath)

-- Load all plugins via your plugins/init.lua
require("plugins")

-- Load modular configs
require("funcs")    -- toggle_detach, safe_bdelete, setup_function_line_count
require("keymaps")  -- keymaps only
require("lsp")      -- LSP setup

