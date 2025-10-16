local detached_buffers = {}

local function safe_bdelete()
    if #vim.fn.getbufinfo { buflisted = 1 } == 1 then
        vim.cmd 'quit'
    else
        vim.cmd 'bdelete!'
    end
end

local function toggle_detach()
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
                vim.api.nvim_buf_set_virtual_text(
                    bufnr, ns_id, end_row,
                    { { '// Function: ' .. line_count .. ' lines', 'Comment' } },
                    {}
                )
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

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error('Error cloning lazy.nvim:\n' .. out)
    end
end

vim.opt.rtp:prepend(lazypath)

return {
    toggle_detach = toggle_detach,
    safe_bdelete = safe_bdelete,
    setup_function_line_count = setup_function_line_count,
}

