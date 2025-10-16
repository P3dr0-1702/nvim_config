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
  
  -- Enable automatic completion after . and -> for C/C++
  if client.name == "clangd" then
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Set up autocommand for member completion
    vim.api.nvim_create_autocmd("TextChangedI", {
      buffer = bufnr,
      callback = function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local line = vim.api.nvim_buf_get_lines(0, cursor[1]-1, cursor[1], true)[1]
        local col = cursor[2]
        
        -- Check if the cursor is right after a '.' or '->'
        if col > 0 then
          local prev_chars = string.sub(line, col-1, col)
          if prev_chars == "." or prev_chars == ">" then
            vim.schedule(function()
              require('cmp').complete({ reason = require('cmp').ContextReason.Auto })
            end)
          end
        end
      end
    })
  end
end

-- Enhanced capabilities with member completion focus
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

-- Member completion settings
capabilities.textDocument.completion.completionItem.resolveSupport.properties = {
  "documentation",
  "detail",
  "additionalTextEdits",
  "labelDetails"
}

-- Add nvim-cmp capabilities if available
local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if has_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Start LSP server for C/C++
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp" },
  callback = function()
    -- Configure completion settings for member access
    vim.opt_local.completeopt = "menu,menuone,noselect"
    
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
        "--enable-config",            -- Use .clangd configuration file if available
        "--all-scopes-completion",    -- Complete in all scopes (important for member completion)
        "--completion-style=detailed", -- Provide more details in completions
        "--function-arg-placeholders", -- Show function arg placeholders
        "--header-insertion-decorators", -- Show where headers come from
        "--include-cleaner-stdlib",     -- Clean up standard library includes
        "--pch-storage=memory",
        "--offset-encoding=utf-16",
      },
      on_attach = on_attach,
      capabilities = capabilities,
      root_dir = vim.fn.getcwd(),
      init_options = {
        clangdFileStatus = true,
        usePlaceholders = true,
        completeUnimported = true,
        semanticHighlighting = true,
      },
      handlers = {
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
