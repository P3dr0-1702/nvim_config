return {
    {
        "neovim/nvim-lspconfig",
        -- Pin to a specific commit or version before the deprecation warnings
        commit = "e49b1e90c1781ce372013de3fa93a91ea29fc34a", -- This is a commit from March 2023
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {},
        opts = {
            -- LSP Server Settings
            servers = {
                -- Add your needed servers here
                clangd = {
                    cmd = {
                        "clangd",
                        "--query-driver=/usr/bin/clang++",
                        "--clang-tidy",
                        "-j=5",
                        "--malloc-trim",
                        "--offset-encoding=utf-16"
                    },
                    filetypes = { "c", "cpp" },
                },
                -- Add other servers if needed
            },
            setup = {},
        },
        config = function(_, opts)
            local on_attach = function(client, bufnr)
                -- Add any additional LSP keybinds here if needed
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
				vim.keymap.set('n', '<C-g>', vim.lsp.buf.definition, bufopts)
			end

            local function setup(server, server_config)
                if opts.setup[server] then
                    if opts.setup[server](server, server_config) then
                        return
                    end
                end
                require("lspconfig")[server].setup(server_config)
            end

            local servers = opts.servers
            local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

            for server, _ in pairs(servers) do
                local server_config = vim.tbl_deep_extend("force", {
                    capabilities = vim.deepcopy(capabilities),
                    on_attach = on_attach,
                }, servers[server] or {})

                setup(server, server_config)
            end
        end,
    }
}
