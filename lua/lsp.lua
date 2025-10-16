-- Enhanced LSP setup for C/C++ development with VSCode-like features

-- Helper function to generate compile_commands.json
local function ensure_compile_commands()
  -- Check if compile_commands.json exists
  if vim.fn.filereadable(vim.fn.getcwd() .. "/compile_commands.json") == 0 then
    -- Create a basic compile_commands.json in the current directory
    local commands = {}
    local headers = vim.fn.glob(vim.fn.getcwd() .. "/**/*.h", false, true)
    local sources = vim.fn.glob(vim.fn.getcwd() .. "/**/*.c", false, true)
    
    -- Add C++ sources if any
    local cpp_sources = vim.fn.glob(vim.fn.getcwd() .. "/**/*.cpp", false, true)
    for _, source in ipairs(cpp_sources) do
      table.insert(sources, source)
    end
    
    -- Generate compile commands for all source files
    for _, source in ipairs(sources) do
      local command = {
        directory = vim.fn.getcwd(),
        command = "gcc -std=c11 -Wall -Wextra -I" .. vim.fn.getcwd() .. " -o " .. 
                 vim.fn.fnamemodify(source, ":r") .. ".o -c " .. source,
        file = source
      }
      table.insert(commands, command)
    end
    
    -- Generate compile commands for all header files (to get intellisense on them)
    for _, header in ipairs(headers) do
      local command = {
        directory = vim.fn.getcwd(),
        command = "gcc -std=c11 -Wall -Wextra -I" .. vim.fn.getcwd() .. " -o /dev/null -c " .. header,
        file = header
      }
      table.insert(commands, command)
    end
    
    -- Write the compile_commands.json file
    local json = vim.fn.json_encode(commands)
    local file = io.open(vim.fn.getcwd() .. "/compile_commands.json", "w")
    if file then
      file:write(json)
      file:close()
      vim.notify("Created compile_commands.json", vim.log.levels.INFO)
    end
  end
end

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

-- Check if nvim-cmp is available
local has_cmp = pcall(require, "cmp")

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
          local prev_char = string.sub(line, col, col)
          local prev_chars = string.sub(line, col-1, col)
          if prev_char == "." or prev_chars == "->" then
            -- If nvim-cmp is available, use it for completion
            if has_cmp then
              vim.schedule(function()
                require('cmp').complete({ reason = require('cmp').ContextReason.Auto })
              end)
            else
              -- Fall back to built-in omnifunc completion
              vim.schedule(function()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-o>', true, true, true), 'n', true)
              end)
            end
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
local cmp_lsp
if has_cmp then
  cmp_lsp = require("cmp_nvim_lsp")
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Add a diagnostic command to check LSP status
vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_active_clients()
  if #clients == 0 then
    vim.notify("No active LSP clients", vim.log.levels.WARN)
    return
  end
  
  local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
  local buf_client_names = {}
  for _, client in pairs(buf_clients) do
    table.insert(buf_client_names, client.name)
  end
  
  local buf_ft = vim.bo.filetype
  vim.notify(
    string.format("Active LSP: %s\nFiletype: %s\nBuffer clients: %s", 
      table.concat(vim.tbl_map(function(client) return client.name end, clients), ", "),
      buf_ft,
      table.concat(buf_client_names, ", ")
    ),
    vim.log.levels.INFO
  )
end, {})

-- Create a command to regenerate the compile_commands.json
vim.api.nvim_create_user_command("RegenerateCompileCommands", function()
  -- Remove existing compile_commands.json if it exists
  if vim.fn.filereadable(vim.fn.getcwd() .. "/compile_commands.json") == 1 then
    os.remove(vim.fn.getcwd() .. "/compile_commands.json")
  end
  
  -- Regenerate the compile_commands.json
  ensure_compile_commands()
  
  -- Restart LSP servers
  vim.cmd("LspRestart")
  
  vim.notify("Regenerated compile_commands.json and restarted LSP servers", vim.log.levels.INFO)
end, {})

-- Add a keybinding for RegenerateCompileCommands
vim.keymap.set("n", "<leader>pc", ":RegenerateCompileCommands<CR>", { noremap = true, silent = true, desc = "Refresh Compilation DB" })

-- Function to check for header issues
local function check_header_issues()
  local bufnr = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  
  -- Only check C/C++ files
  local filetype = vim.bo[bufnr].filetype
  if not (filetype == "c" or filetype == "cpp") then
    return
  end
  
  -- Read the file content
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")
  
  -- Check for includes
  local includes = {}
  for include in content:gmatch('#include%s*[<"]([^>"]+)[>"]') do
    table.insert(includes, include)
  end
  
  -- Check for struct definitions
  local has_struct = content:match("typedef%s+struct") ~= nil
  
  -- If file has struct definitions but no one is including it, warn the user
  if has_struct and vim.fn.glob(vim.fn.getcwd() .. "/**/*.[ch]", false, true) > 0 then
    local included_count = 0
    local all_sources = vim.fn.glob(vim.fn.getcwd() .. "/**/*.[ch]", false, true)
    
    for _, source_file in ipairs(all_sources) do
      if source_file ~= file_path then
        local source_content = vim.fn.readfile(source_file)
        local source_text = table.concat(source_content, "\n")
        
        local file_name = vim.fn.fnamemodify(file_path, ":t")
        if source_text:match('#include%s*[<"]' .. file_name .. '[>"]') then
          included_count = included_count + 1
        end
      end
    end
    
    if included_count == 0 and has_struct then
      vim.notify("Warning: This file contains struct definitions but isn't included anywhere in the project.", vim.log.levels.WARN)
    end
  end
end

-- Check header issues on file open and save
vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
  pattern = {"*.h", "*.c", "*.hpp", "*.cpp"},
  callback = check_header_issues,
})

-- Start LSP server for C/C++
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp" },
  callback = function()
    -- Configure completion settings for member access
    vim.opt_local.completeopt = "menu,menuone,noselect"
    
    -- Ensure compile_commands.json exists
    ensure_compile_commands()
    
    -- Start server if not already started
    vim.lsp.start({
      name = "clangd",
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--compile-commands-dir=" .. vim.fn.getcwd(), -- Use compile_commands.json
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--suggest-missing-includes",
        "--cross-file-rename",
        "--all-scopes-completion",
        "--pch-storage=memory",
        "--log=verbose", -- Increase logging to diagnose issues
        "--query-driver=/usr/bin/gcc,/usr/bin/g++,/usr/bin/clang,/usr/bin/clang++",
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

-- Create a keymap to toggle struct member visibility
vim.api.nvim_create_user_command("ToggleStructMembers", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_buf_get_lines(0, cursor[1]-1, cursor[1], true)[1]
  
  -- Find struct variable name under cursor
  local var_name = line:match("%S+%s*$"):gsub("%s+", "")
  if not var_name then return end
  
  -- Request completions for this struct
  vim.lsp.buf.completion({
    context = { triggerKind = 2 }, -- Trigger kind 2 = TriggerKind.TriggerCharacter
    triggerCharacter = "."
  })
end, {})

-- Export functions for use elsewhere
return {
  generate_compile_commands = ensure_compile_commands,
  check_header_issues = check_header_issues
}
