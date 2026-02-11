return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      mode = "buffers",
      groups = {
        items = {
          {
            name = "outside_cwd",
            highlight = { fg = "#ff9e64", bg = "#2a1f1a", bold = true },
            matcher = function(buf)
            if not buf.path or buf.path == "" then
              return false
              end
              local cwd = vim.loop.fs_realpath(vim.fn.getcwd()) or vim.fn.getcwd()
              local path = vim.loop.fs_realpath(buf.path) or buf.path
              return not vim.startswith(path, cwd .. "/")
              end,
          },
        },
      },
    },
  },
}
