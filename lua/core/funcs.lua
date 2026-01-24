-- ~/.config/nvim/lua/funcs.lua

local detached_buffers = {}

local M = {}

-- Safe buffer delete with NvimTree fallback
function M.safe_bdelete()
    local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })
    local current_buf = vim.api.nvim_get_current_buf()

    -- LAST BUFFER CASE
    if #listed_buffers <= 1 then
        -- Open NvimTree if not already open
        local tree_winnr = vim.fn.bufwinnr('NvimTree')
        if tree_winnr == -1 then
            vim.cmd('NvimTreeOpen')
            tree_winnr = vim.fn.bufwinnr('NvimTree')
        end

        -- Focus NvimTree and make it fullscreen
        if tree_winnr ~= -1 then
            vim.cmd(tree_winnr .. 'wincmd w')
            vim.cmd('only')
        end

        -- HARD delete the buffer (no replacement buffer)
        if vim.api.nvim_buf_is_valid(current_buf) then
            vim.api.nvim_buf_delete(current_buf, { force = true })
        end

        return
    end

    -- MULTIPLE BUFFERS CASE
    local next_buf = nil

    for _, buf in ipairs(listed_buffers) do
        if buf.bufnr ~= current_buf
            and vim.api.nvim_buf_is_valid(buf.bufnr)
            and vim.api.nvim_get_option_value('filetype', { buf = buf.bufnr }) ~= 'NvimTree'
		then
            next_buf = buf.bufnr
            break
        end
    end

    -- Switch first, then delete (prevents flicker)
    if next_buf then
        vim.api.nvim_set_current_buf(next_buf)
    end

    vim.api.nvim_buf_delete(current_buf, { force = true })
end-- Function to save and close buffer
function M.save_and_close()
    vim.cmd('write')  -- Save the file
    M.safe_bdelete()  -- Then close it properly
end

function M.safe_bdelete_all()
    -- Ensure NvimTree is open and focused
    if vim.fn.bufwinnr('NvimTree') == -1 then
        vim.cmd('NvimTreeOpen')
    end
    local tree_winnr = vim.fn.bufwinnr('NvimTree')
    if tree_winnr ~= -1 then
        vim.cmd(tree_winnr .. 'wincmd w')
        vim.cmd('only')
    end

    -- Collect all listed buffers that are not NvimTree
    local to_delete = {}
    for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        local bufnr = buf.bufnr
        if vim.api.nvim_buf_is_valid(bufnr)
            and vim.api.nvim_get_option_value('filetype', { buf = bufnr }) ~= 'NvimTree'
		then
            table.insert(to_delete, bufnr)
        end
    end

    -- Delete them
    for _, bufnr in ipairs(to_delete) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end
    end
end

function M.save_all_and_bdelete_all()
  pcall(function() vim.cmd('wa') end)
  M.safe_bdelete_all()
end-- Toggle detach buffer to new terminal

function M.toggle_detach()
    local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':.')
    if bufname == '' then
        vim.notify('Cannot detach an empty buffer', vim.log.levels.WARN)
        return
    end

    if detached_buffers[bufname] then
        -- Reattach
        vim.cmd('edit ' .. bufname)
        detached_buffers[bufname] = nil
        vim.notify('Buffer reattached', vim.log.levels.INFO)
        return
    end

    -- Detach buffer in a new terminal
    local cmd = string.format('konsole --noclose -e zsh -i -c "nvim %q"', bufname)
    vim.fn.jobstart(cmd, { detach = true })

    detached_buffers[bufname] = true

    -- Close current buffer
    local current_bufnr = vim.api.nvim_get_current_buf()
    vim.cmd('bdelete! ' .. current_bufnr)

    -- Close any remaining no-name buffers
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) == '' then
            pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
        end
    end

    vim.notify('Buffer detached to new Konsole', vim.log.levels.INFO)
end

-- Auto-delete extra no-name buffers
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr)
                and vim.api.nvim_buf_get_name(bufnr) == ''
                and vim.fn.buflisted(bufnr) == 1
                and bufnr ~= vim.api.nvim_get_current_buf()
            then
                vim.api.nvim_buf_delete(bufnr, { force = true })
            end
        end
    end
})

-- Run c_formatter_42 with <leader>i
vim.keymap.set('n', '<leader>i', function()
    vim.cmd 'silent! write'
    vim.cmd '!c_formatter_42 %'
    vim.cmd 'edit!'
end, { noremap = true, silent = true, desc = 'Format with 42 formatter' })

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Show function line counts in C/C++ files
local function setup_function_line_count()
    local ns_id = vim.api.nvim_create_namespace 'function_line_count'

    local function update_line_counts()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

        local filename = vim.api.nvim_buf_get_name(bufnr)
        if not filename or filename == "" or filename:match("%.[hH][pP]?[pP]?$") then
            return
        end

        local has_ts, _ = pcall(require, 'nvim-treesitter.locals')
        if not has_ts then return end

        local parsers = require 'nvim-treesitter.parsers'
        if not parsers.has_parser() then return end

        local parser = parsers.get_parser()
        if not parser then return end

        local trees = parser:parse()
        if not trees or #trees == 0 then return end

        local root = trees[1]:root()
        local filetype = vim.bo.filetype
        local query_string

        if filetype == 'c' then
            query_string = [[
                (function_definition) @function
            ]]
        elseif filetype == 'cpp' then
            query_string = [[
                (function_definition) @function
                (method_definition) @function
            ]]
        else
            return
        end

        local success, query = pcall(vim.treesitter.query.parse, filetype, query_string)
        if not success or not query then return end

        for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
            if query.captures[id] == 'function' then
                local start_row, _, end_row, _ = node:range()
                local line_count = end_row - start_row + 1 - 3
                vim.api.nvim_buf_set_extmark(bufnr, ns_id, end_row, 0, {
				    virt_text = {
				        { '// Function: ' .. line_count .. ' lines', 'Comment' },
				    },
				    virt_text_pos = 'eol',
				})

            end
        end
    end

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'TextChanged', 'TextChangedI' }, {
        callback = function()
            local filename = vim.api.nvim_buf_get_name(0)
            if (vim.bo.filetype == 'c' or vim.bo.filetype == 'cpp')
                and filename ~= ""
                and not filename:match("%.[hH][pP]?[pP]?$")
            then
                pcall(update_line_counts)
            end
        end,
    })
end

-- Initialize the function line count feature
setup_function_line_count()

-- Return module table
return M
