return
{

	{return {
    {
        'neovim/nvim-lspconfig',
        config = function()
            local lspconfig = require('lspconfig')

            lspconfig.clangd.setup {
                cmd = { 'clangd', '--background-index', '--clang-tidy' },
                filetypes = { 'c', 'cpp', 'objc', 'objcpp' },

                root_dir = function()
                    return vim.fn.getcwd()
                end,

                on_attach = function(_, bufnr)
                    local opts = { buffer = bufnr, noremap = true, silent = true }

                    -- LSP keymaps
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                end,
            }
        end,
    }
}

