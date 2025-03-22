local M = {}

local api = vim.api
local fn = vim.fn
local utils = require("config.utils")

local function drop_undo(buf)
    local undolevels = vim.o.undolevels
    vim.bo[buf].undolevels = -1
    vim.cmd([[exe "normal a \<bs>\<esc>"]])
    vim.bo[buf].undolevels = undolevels

    vim.bo[buf].modified = false
end

local function xxd_disassemble(buf)
    vim.b[buf].xxd_is_dumped = true
    vim.cmd.undojoin()
    vim.cmd { cmd = "!",
        args = { "xxd" },
        range = { 0, api.nvim_buf_line_count(buf) },
        mods = { silent = true }
    }
end

local function xxd_reassemble(buf)
    vim.b[buf].xxd_is_dumped = false
    vim.cmd { cmd = "!",
        args = { "xxd -r" },
        range = { 0, api.nvim_buf_line_count(buf) },
        mods = { silent = true }
    }
    vim.cmd.undojoin()
end


function M.attach(buf)
    if buf == 0 then
        buf = api.nvim_get_current_buf()
    end

    if vim.b[buf].xxd_last_pos then
        return
    end

    local lsps = vim.lsp.get_clients { bufnr = buf }
    for _, lsp in ipairs(lsps) do
        lsp.stop()
    end
    vim.b[buf].xxd_last_ft = vim.bo[buf].ft

    vim.b[buf].xxd_last_pos = { 1, 0 }
    vim.bo[buf].ft = "xxd"

    xxd_disassemble(buf)
    drop_undo(buf)

    local augroup
    augroup = utils.autogroup(("config.xxd.%d"):format(buf), {
        BufWritePre = function()
            -- make undo correspond exactly, this may fail, we dont care
            -- nevertheless, undo will always be slow for large files
            pcall(vim.cmd.undojoin)
            vim.b[buf].xxd_last_pos = api.nvim_win_get_cursor(0)
            xxd_reassemble(buf)
        end,

        BufWritePost = function()
            xxd_disassemble(buf)
            api.nvim_win_set_cursor(0, vim.b[buf].xxd_last_pos)
            vim.bo[buf].modified = false
        end,

        BufDelete = function()
            api.nvim_del_augroup_by_id(augroup)
        end
    }, { buf = buf })

    api.nvim_buf_create_user_command(buf, "Mq", function()
        api.nvim_del_augroup_by_id(augroup)
        if vim.b[buf].xxd_is_dumped then
            xxd_reassemble(buf)
            drop_undo(buf)
            vim.b[buf].xxd_last_pos = nil
            api.nvim_buf_del_user_command(buf, "Mq")

            vim.bo[buf].ft = vim.b[buf].xxd_last_ft
            vim.b[buf].xxd_last_ft = nil
        end
    end, { nargs = 0, desc = "Quit xxd mode" })
end

return M
