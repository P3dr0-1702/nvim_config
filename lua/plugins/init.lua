-- lua/plugins/init.lua
local plugin_files = {
  "42_header", "toggle_term", "dev_webicons", "gitsigns",
  "whichkey", "telescope", "mini_pairs", "buffer_line",
  "conform", "lazydev", "todo-comment", "lsp",
  "treesitter", "completion", "project_helper",
  "kanagawa", "vim_mmulti_cursor",
}

local plugins = {}

for _, name in ipairs(plugin_files) do
  local ok, tbl = pcall(require, "plugins.plugins." .. name)
  if ok and tbl then
    for _, plugin in ipairs(tbl) do
      table.insert(plugins, plugin)
    end
  end
end

return plugins
