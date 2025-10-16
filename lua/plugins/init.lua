-- lua/plugins/init.lua
local plugin_files = {
  "42_header", "toggle_term", "dev_webicons", "gitsigns",
  "whichkey", "telescope", "mini_pairs", "buffer_line",
  "blink", "conform", "lazydev", "todo-comment",
  "tokyonight", "treesitter",
}

local plugins = {}

for _, name in ipairs(plugin_files) do
  local ok, tbl = pcall(require, "plugins.plugins." .. name)
  if ok and tbl then
    for _, plugin in ipairs(tbl) do
      table.insert(plugins, plugin)
    end
  end
end

-- Add LSP plugin directly here
table.insert(plugins, {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- Same LSP setup code as in the first example
    -- Setup diagnostic signs
    local signs = {
      Error = " ",
      Warn = " ",
      Hint = " ",
      Info = " "
    }
    
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
    
    -- Configure diagnostics display
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = "always",
      },
    })
    
    -- Define on_attach function
    local on_attach = function(_, bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }
      
      -- LSP keybindings
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
    end
    
    -- Start LSP for C/C++
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "c", "cpp", "objc", "objcpp" },
      callback = function()
        vim.lsp.start({
          name = "clangd",
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--header-insertion=iwyu",
            "--fallback-style=llvm",
            "--all-scopes-completion"
          },
          on_attach = on_attach,
          capabilities = vim.lsp.protocol.make_client_capabilities(),
          root_dir = vim.fn.getcwd()
        })
      end,
    })
  end
})

return plugins
