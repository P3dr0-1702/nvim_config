-- Enhanced LSP setup for C/C++ development with VSCode-like features

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
local on_attach = function(client, bufnr)
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
  
  -- Setup inlay hints
  if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
    -- Enable inlay hints by default
    vim.lsp.inlay_hint.enable(bufnr, true)
    
    -- Toggle inlay hints with leader+h
    vim.keymap.set("n", "<leader>h", function()
      vim.lsp.inlay_hint.enable(bufnr, not vim.lsp.inlay_hint.is_enabled(bufnr))
    end, { buffer = bufnr, desc = "Toggle Inlay Hints" })
  end
  
  -- Create autocommand to show diagnostics on cursor hold
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      vim.diagnostic.open_float(nil, { focus = false })
    end,
  })
end

-- Configure capabilities for autocompletion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    "documentation",
    "detail",
    "additionalTextEdits",
  },
}
capabilities.textDocument.completion.completionItem.preselectSupport = true
capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
capabilities.textDocument.completion.completionItem.deprecatedSupport = true
capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }

-- Add nvim-cmp capabilities if available
local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if has_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Start LSP server for C/C++
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp" },
  callback = function()
    -- Start server if not already started
    vim.lsp.start({
      name = "clangd",
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--suggest-missing-includes",
        "--cross-file-rename",
        "--completion-style=bundled",
        "--fallback-style=llvm",
        "--all-scopes-completion",
        "--pch-storage=memory",
        "--offset-encoding=utf-16", -- needed for null-ls
        "--header-insertion-decorators",
        "--function-arg-placeholders",
        "--ranking-model=decision_forest"
      },
      on_attach = on_attach,
      capabilities = capabilities,
      root_dir = vim.fn.getcwd(),
      handlers = {
        -- Custom handlers for better integration
        ["textDocument/hover"] = vim.lsp.with(
          vim.lsp.handlers.hover, { border = "rounded" }
        ),
        ["textDocument/signatureHelp"] = vim.lsp.with(
          vim.lsp.handlers.signature_help, { border = "rounded" }
        ),
      }
    })
  end,
})

-- Add the completion plugin to your plugins list
if not vim.tbl_contains(require("plugins"), "hrsh7th/nvim-cmp") then
  vim.notify("Please make sure to add the completion.lua to your plugins directory", vim.log.levels.WARN)
end
