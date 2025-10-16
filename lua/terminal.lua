-- Enhanced Terminal Toggle functionality (uses your system terminal environment)
local Terminal = {
  buf = nil,
  win = nil,
  term = nil,
  height = 15, -- Height of the terminal window
}

function Terminal:toggle()
  if self.win and vim.api.nvim_win_is_valid(self.win) then
    -- Terminal is visible, hide it
    vim.api.nvim_win_hide(self.win)
    self.win = nil
    return
  end

  if not self.buf or not vim.api.nvim_buf_is_valid(self.buf) then
    -- Create a new terminal buffer if needed
    self.buf = vim.api.nvim_create_buf(false, true)
    
    -- Get the user's login shell to ensure all environment variables and configs are loaded
    local shell = os.getenv("SHELL") or vim.o.shell
    
    -- Open terminal with full environment
    -- The empty table parameter ensures we inherit the parent process environment
    self.term = vim.fn.termopen(shell, {
      detach = 0,
      env = {}, -- Empty table means inherit all environment variables
      cwd = vim.fn.getcwd() -- Start in the current working directory
    })
  end

  -- Create a new window at the bottom
  local width = vim.o.columns
  local height = self.height
  
  self.win = vim.api.nvim_open_win(self.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = 0,
    row = vim.o.lines - height - 1, -- Position at bottom
    style = "minimal",
    border = "single",
  })

  -- Set some window-local options
  vim.wo[self.win].winblend = 0
  vim.wo[self.win].number = false
  vim.wo[self.win].relativenumber = false
  vim.wo[self.win].cursorline = false
  
  -- Automatically enter insert mode when opening terminal
  vim.cmd("startinsert")
end

-- Create keymapping for toggling terminal
vim.keymap.set('n', '<leader>t', function() Terminal:toggle() end, { noremap = true, silent = true, desc = "Toggle Terminal" })

-- Terminal mode mappings to make it behave more like your regular terminal
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })

-- Optional: Add more terminal mode mappings for common terminal shortcuts
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>', { noremap = true, silent = true }) -- Window navigation from terminal
