---@type config.overlay
---@diagnostic disable-next-line: missing-fields
local M = {}

local api = vim.api
local utils = require("config.utils")

local function drop_undo(buf)
    local undolevels = vim.o.undolevels
    vim.bo[buf].undolevels = -1
    vim.cmd([[exe "normal a \<bs>\<esc>"]])
    vim.bo[buf].undolevels = undolevels

    vim.bo[buf].modified = false
end

local function xxd_disassemble(buf)
    M.state[buf].is_dumped = true
    vim.cmd.undojoin()
    vim.cmd { cmd = "!",
        args = { "xxd" },
        range = { 0, api.nvim_buf_line_count(buf) },
        mods = { silent = true }
    }
end

local function xxd_reassemble(buf)
    M.state[buf].is_dumped = false
    vim.cmd { cmd = "!",
        args = { "xxd -r" },
        range = { 0, api.nvim_buf_line_count(buf) },
        mods = { silent = true }
    }
    vim.cmd.undojoin()
end

---@type table<integer, {last_pos: [integer, integer], is_dumped: boolean, prev_ft: string?, augroup: integer}>
M.state = {}


function M.attach(buf, ...)
    if buf == 0 then
        buf = api.nvim_get_current_buf()
    end

    if M.state[buf] then
        vim.notify("Xxd: Already attached", vim.log.levels.ERROR)
        return false
    end

    local lsps = vim.lsp.get_clients { bufnr = buf }
    for _, lsp in ipairs(lsps) do
        lsp.stop()
    end
    local state = {
        last_ft = vim.bo[buf].ft,
        last_pos = { 1, 0 },
        is_dumped = false,
    }
    M.state[buf] = state

    vim.bo[buf].ft = "xxd"

    xxd_disassemble(buf)
    drop_undo(buf)

    local augroup
    augroup = utils.autogroup(("config.xxd.%d"):format(buf), {
        BufWritePre = function()
            -- make undo correspond exactly, this may fail, we dont care
            -- nevertheless, undo will always be slow for large files
            pcall(vim.cmd.undojoin)
            state.last_pos = api.nvim_win_get_cursor(0)
            xxd_reassemble(buf)
        end,

        BufWritePost = function()
            xxd_disassemble(buf)
            api.nvim_win_set_cursor(0, state.last_pos)
            vim.bo[buf].modified = false
        end,

        BufDelete = function()
            api.nvim_del_augroup_by_id(augroup)
        end
    }, { buf = buf })

    state.augroup = augroup

    return true
end

function M.detach(buf)
    local state = M.state[buf]
    if not state then
        return
    end

    api.nvim_del_augroup_by_id(state.augroup)
    if state.is_dumped then
        xxd_reassemble(buf)
        drop_undo(buf)

        vim.bo[buf].ft = state.prev_ft
    end

    M.state[buf] = nil
end

return M
