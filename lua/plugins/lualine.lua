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

    local lock_state = { caps = false, num = false }

    ---@param lock_name string e.g. "capslock" or "numlock"
    ---@return boolean
    local function read_lock_sysfs(lock_name)
      local pattern = "/sys/class/leds/input*::" .. lock_name .. "/brightness"
      local paths = vim.fn.glob(pattern, false, true)
      for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
          local val = file:read("*l")
          file:close()
          if val and tonumber(val) == 1 then
            return true
          end
        end
      end
      return false
    end

    local function refresh_lock_state()
      lock_state.caps = read_lock_sysfs("capslock")
      lock_state.num = read_lock_sysfs("numlock")
    end

    -- Poll every 100ms — sysfs reads are microseconds, so this is essentially free
    local timer = vim.uv.new_timer()
    if timer then
      timer:start(0, 100, vim.schedule_wrap(refresh_lock_state))
    end

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
        lualine_a = {
          "mode",

          -- ⬤ CAPS LOCK — bright red, bold, impossible to miss
          {
            function()
              return "⬤ CAPS"
            end,
            cond = function()
              return lock_state.caps
            end,
            color = { fg = "#112638", bg = "#FF4A4A", gui = "bold" },
          },
        },

        lualine_b = {
          "branch",
          "diff",
        },

        lualine_c = {
          {
            "filename",
            path = 1,
          },
        },

        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },

          -- Num Lock — subtle small indicator, far right
          {
            function()
              return "󰎠"
            end,
            cond = function()
              return lock_state.num
            end,
            color = { fg = colors.gray },
          },

          {
            function()
              return " " .. os.date("%H:%M")
            end,
            color = { fg = colors.blue },
          },

          {
            function()
              return " " .. os.date("%d/%m/%Y")
            end,
            color = { fg = colors.yellow },
          },

          { "encoding" },

          { "fileformat", symbols = { unix = "" } },

          { "filetype" },
        },

        lualine_y = { "progress" },

        lualine_z = {
          "location",
        },
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
