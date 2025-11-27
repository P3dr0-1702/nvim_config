return
{
  "mg979/vim-visual-multi",
  branch = "master",
  config = function()
    -- Restore your whitespace settings after VM loads
    vim.opt.list = true
    vim.opt.listchars = {
      tab   = '» ',
      space = '·',
      trail = '·',
      nbsp  = '␣',
    }
  end
}

