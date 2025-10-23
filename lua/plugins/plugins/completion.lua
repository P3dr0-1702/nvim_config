-- Updated completion.lua: make Tab confirm selection (not cycle), make Enter only confirm when menu visible,
-- and avoid auto-selecting the first item (select = false) to prevent accidental completions/snippet expansions.

return {
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",           -- LSP completion source
      "hrsh7th/cmp-buffer",             -- Buffer completions
      "hrsh7th/cmp-path",               -- Path completions
      "saadparwaiz1/cmp_luasnip",       -- Snippet completions
      "hrsh7th/cmp-nvim-lsp-signature-help", -- Function signature help
      "L3MON4D3/LuaSnip",               -- Snippet engine
      "rafamadriz/friendly-snippets",   -- Snippet collection
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      -- Load friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          -- Limit the window height to fix the "too big" issue
          completion = {
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
            max_height = 10, -- Limit height
            max_width = 50,  -- Limit width
          },
          documentation = {
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
            max_height = 15,
            max_width = 60,
          },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),

          -- Enter: confirm only when menu is visible. Otherwise insert newline (fallback).
          -- select = false prevents auto-selecting first item when nothing explicitly selected.
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- Tab: if completion menu visible, confirm the currently selected item (don't move to next),
          -- else expand/jump snippets, else fallback to normal Tab behavior.
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- Shift-Tab: go to previous item or jump backwards in snippet, else fallback
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = {
          -- CRITICAL: Only use LSP for dot completions, buffer is lower priority
          { name = 'nvim_lsp', priority = 1000, trigger_characters = {'.', ':', '->', ':'} },
          { name = 'nvim_lsp_signature_help', priority = 900 },
          { name = 'luasnip', priority = 750 },
          { name = 'buffer', priority = 500, max_item_count = 5, keyword_length = 4 }, -- Reduce buffer importance
          { name = 'path', priority = 250 },
        },
        formatting = {
          format = function(entry, vim_item)
            -- Set a name for each source
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end
        },
        completion = {
          keyword_length = 1,        -- Show completions after typing just 1 character
          completeopt = "menu,menuone,noinsert",
        },
        experimental = {
          ghost_text = true,  -- Shows ghost text like VSCode
        },
      })
      
      -- Special handling for struct member completion
      cmp.setup.filetype({ 'c', 'cpp' }, {
        sources = {
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'nvim_lsp_signature_help', priority = 900 },
          { name = 'luasnip', priority = 750 },
          { name = 'buffer', priority = 100, keyword_length = 5 }, -- Even lower priority for C/C++
        }
      })

      -- Special handling for dot completion
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"c", "cpp"},
        callback = function()
          -- Override behavior for completion after . and ->
          cmp.event:on("menu_opened", function()
            if vim.fn.mode() == "i" then
              local line = vim.api.nvim_get_current_line()
              local cursor = vim.api.nvim_win_get_cursor(0)
              local col = cursor[2]
              
              -- If we're after a dot or ->, hide buffer completions
              if col > 0 then
                local prev_char = string.sub(line, col, col)
                local prev_chars = string.sub(line, col-1, col)
                
                if prev_char == "." or prev_chars == "->" then
                  -- Force LSP-only completion
                  cmp.setup.buffer({
                    sources = {
                      { name = 'nvim_lsp' },
                      { name = 'nvim_lsp_signature_help' },
                    }
                  })
                  
                  -- Restore normal sources after a delay
                  vim.defer_fn(function()
                    cmp.setup.buffer({
                      sources = {
                        { name = 'nvim_lsp', priority = 1000 },
                        { name = 'nvim_lsp_signature_help', priority = 900 },
                        { name = 'luasnip', priority = 750 },
                        { name = 'buffer', priority = 100, keyword_length = 5 },
                      }
                    })
                  end, 2000)
                end
              end
            end
          end)
        end
      })
    end
  }
}
