return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
  local lualine = require("lualine")
  local lazy_status = require("lazy.status")

  local colors = {
    blue = "#65D1FF",
    green = "#3EFFDC",
    violet = "#FF61EF",
    yellow = "#FFDA7B",
    red = "#FF4A4A",
    fg = "#c3ccdc",
    bg = "#112638",
    inactive_bg = "#2c3043",
    gray = "#7f8490",
  }

  local my_lualine_theme = {
    normal = {
      a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
      b = { bg = colors.bg, fg = colors.fg },
      c = { bg = colors.bg, fg = colors.fg },
    },
    insert = {
      a = { bg = colors.green, fg = colors.bg, gui = "bold" },
      b = { bg = colors.bg, fg = colors.fg },
      c = { bg = colors.bg, fg = colors.fg },
    },
    visual = {
      a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
      b = { bg = colors.bg, fg = colors.fg },
      c = { bg = colors.bg, fg = colors.fg },
    },
    command = {
      a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
      b = { bg = colors.bg, fg = colors.fg },
      c = { bg = colors.bg, fg = colors.fg },
    },
    replace = {
      a = { bg = colors.red, fg = colors.bg, gui = "bold" },
      b = { bg = colors.bg, fg = colors.fg },
      c = { bg = colors.bg, fg = colors.fg },
    },
    inactive = {
      a = { bg = colors.inactive_bg, fg = colors.gray, gui = "bold" },
      b = { bg = colors.inactive_bg, fg = colors.gray },
      c = { bg = colors.inactive_bg, fg = colors.gray },
    },
  }

  lualine.setup({
    options = {
      theme = my_lualine_theme,
      component_separators = { left = ">>", right = "<<" },
      section_separators = { left = "", right = "" },
    },

    sections = {
      lualine_a = { "mode" },

      lualine_b = { "branch", "diff" },

      lualine_c = {
        {
          "filename",
          path = 1,
        },
      },

      lualine_x = {

        -- Lazy.nvim updates
        {
          lazy_status.updates,
          cond = lazy_status.has_updates,
          color = { fg = "#ff9e64" },
        },

        -- 24h clock
        {
          function()
          return " " .. os.date("%H:%M")
          end,
          color = { fg = colors.blue },
        },

        -- date
        {
          function()
          return " " .. os.date("%d/%m/%Y")
          end,
          color = { fg = colors.yellow },
        },

        { "encoding" },

        { "fileformat", symbols = { unix = "" } },

        { "filetype" },
      },

      lualine_y = { "progress" },

      lualine_z = { "location" },
    },

    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
  })
  end,
}
