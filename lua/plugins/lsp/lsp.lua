return {
  "hrsh7th/cmp-nvim-lsp",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/lazydev.nvim", opts = {} },
  },
  config = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- global LSP defaults
    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    -- clangd-specific override
    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--header-insertion=never",
		"--clang-tidy",
		"--clang-tidy-checks=-clang-diagnostic-unused-include",
      },
    })
  end,
}
