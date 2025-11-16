-- STABLE terminal.lua for NeoVim

local Terminal = {
  buf = nil,
  win = nil,
  job_id = nil,
  height = 15,
}

function Terminal:toggle()
  if self.win and vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_hide(self.win)
    self.win = nil
    return
  end

  -- Create buffer if missing or invalid
  if not self.buf or not vim.api.nvim_buf_is_valid(self.buf) then
    self.buf = vim.api.nvim_create_buf(false, true)

    local shell = os.getenv("SHELL") or vim.o.shell
    vim.cmd("lcd " .. vim.fn.getcwd())

    -- IMPORTANT: start term before opening window
    vim.api.nvim_buf_call(self.buf, function()
      self.job_id = vim.fn.termopen(shell)
    end)
  end

  -- Open floating window
  local width = vim.o.columns
  local height = self.height
  self.win = vim.api.nvim_open_win(self.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = 0,
    row = vim.o.lines - height,
    style = "minimal",
    border = "single",
  })

  vim.wo[self.win].winfixheight = true
  vim.wo[self.win].number = false
  vim.wo[self.win].relativenumber = false
  vim.cmd("startinsert")
end

vim.keymap.set('n', '<leader>t', function()
  Terminal:toggle()
end, { noremap = true, silent = true, desc = "Toggle Terminal" })

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*',
  group = vim.api.nvim_create_augroup('MyTerminalMaps', { clear = true }),
  callback = function()
    local opts = { buffer = 0, noremap = true, silent = true }
    vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], opts)
    vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], opts)
    vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], opts)
    vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], opts)
  end,
})

