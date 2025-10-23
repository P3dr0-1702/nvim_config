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
require("terminal")

-- Load all plugins via your plugins/init.lua
require("lazy").setup(require("plugins"))

-- Enable the lua-loader for better performance
vim.loader.enable()

-- Basic options
require("config.options")

-- Load lazy plugin manager (fixed path)
require("config.lazy") -- Change this line to point to the correct path

-- Configure diagnostics for LSP
vim.diagnostic.config({
  virtual_text = true,
  float = {
    border = "rounded",
    focusable = false,
  },
  severity_sort = true,
})

-- Configure LSP handlers
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "rounded",
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = "rounded",
  }
)

-- Auto Save

vim.api.nvim_create_autocmd({"InsertLeave", "TextChanged"}, {
  pattern = "*",
  command = "silent! wall"
})
