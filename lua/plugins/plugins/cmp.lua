return {
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp-signature-help",
        },
        config = function(_, opts)
            local cmp = require("cmp")
            cmp.setup(opts)
        end,
        opts = function()
            local cmp = require("cmp")
            
            return {
                snippet = {
                    expand = function(args)
                        -- You can use any snippet engine here if needed
                        -- or just keep this empty if you don't need snippets
                    end,
                },
                window = {
                    completion = { border = "rounded" },
                    documentation = { border = "rounded" },
                },
                formatting = {
                    format = function(entry, vim_item)
                        local icons = require("config.defaults").icons.kinds
                        -- Kind icons
                        vim_item.kind = string.format("%s", icons[vim_item.kind])
                        -- Source
                        vim_item.menu = ({
                            buffer = "[Buffer]",
                            nvim_lsp = "[LSP]",
                            path = "[Path]",
                        })[entry.source.name]
                        return vim_item
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = 'nvim_lsp_signature_help' }
                }),
            }
        end
    }
}
