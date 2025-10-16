return {
  {
    "folke/which-key.nvim", -- Assuming you have which-key already
    optional = true,
    opts = function(_, opts)
      -- Add project management commands
      if opts.defaults then
        opts.defaults["<leader>p"] = { name = "+project" }
        opts.defaults["<leader>pc"] = { function() 
          local lsp = require('lsp')
          lsp.generate_compile_commands() 
          vim.notify("Refreshed compile_commands.json", vim.log.levels.INFO)
          -- Restart clangd
          vim.cmd("LspRestart")
        end, "Refresh Compilation DB" }
        
        -- Add a command to debug struct completion
        opts.defaults["<leader>pd"] = {
          function()
            vim.cmd("DebugStructCompletion")
          end,
          "Debug Struct Completion"
        }
        
        -- Add a command to show struct members
        opts.defaults["<leader>ps"] = {
          function()
            vim.cmd("ToggleStructMembers")
          end,
          "Show Struct Members"
        }
        
        -- Add command to view LSP logs
        opts.defaults["<leader>pl"] = {
          function()
            vim.cmd("LspLog")
          end,
          "View LSP Logs"
        }
      end
    end,
  }
}
