return {
  {
    "folke/which-key.nvim", -- Assuming you have which-key already
    optional = true,
    opts = function(_, opts)
      local lsp = require('lsp')
      
      -- Add project management commands
      if opts.defaults then
        opts.defaults["<leader>p"] = { name = "+project" }
        opts.defaults["<leader>pc"] = { 
          function() 
            lsp.generate_compile_commands() 
            vim.notify("Refreshed compile_commands.json", vim.log.levels.INFO)
            -- Restart clangd
            vim.cmd("LspRestart")
          end, 
          "Refresh Compilation DB" 
        }
        
        opts.defaults["<leader>ph"] = {
          function()
            lsp.check_header_issues()
          end,
          "Check Header Issues"
        }
        
        -- Add a command to show struct members
        opts.defaults["<leader>ps"] = {
          function()
            vim.cmd("ToggleStructMembers")
          end,
          "Show Struct Members"
        }
      end
    end,
  },
  
  -- You can add more project management plugins here
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      -- Ensure C/C++ parsers are installed
      if not opts.ensure_installed then
        opts.ensure_installed = {}
      end
      
      table.insert(opts.ensure_installed, "c")
      table.insert(opts.ensure_installed, "cpp")
    end,
  }
}