return {
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has('win32') == 1 or vim.fn.executable('make') == 0 then return end
          return 'make install_jsregexp'
        end)(),
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
      'folke/lazydev.nvim',
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
    },
    opts = {
      keymap = { preset = 'super-tab' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
        sorting = {
          comparators = { 'locality', 'recently_used', 'score', 'kind', 'length' },
        },
        list = { max_items = 30 },
      },
      sources = {
        default = { 'buffer', 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
          buffer = {},
          lsp = {
            transform_items = function(items)
              for _, item in ipairs(items) do
                if item.kind == vim.lsp.protocol.CompletionItemKind.Function then
                  local clean = item.label:match('([^(]+)')
                  if clean then item.label = clean end
                end
              end
              return items
            end,
          },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },
}

