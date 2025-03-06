local M = {}
local api = vim.api

local function get_exec_line(name, msg)
    local line = msg and msg:match("^" .. vim.pesc(name) .. ":(%d+):")
    if line then
        return tonumber(line)
    end

    for lvl = 2, 20 do
        local info = debug.getinfo(lvl, "Sln")
        if info and info.source == "@" .. name then
            return info.currentline
        end
    end
end

local function get_source_line_length(scratch, linenr)
    return #api.nvim_buf_get_lines(scratch.buf, linenr, linenr + 1, false)[1]
end

local function debug_print(scratch, ...)
    local str = table.concat(vim.tbl_map(function(v)
        return vim.inspect(v)
    end, { ... }), ", ")
    local lines = vim.split(str, "\n", { plain = true })
    local linenr = (get_exec_line(scratch.name) or 1) - 1
    if #lines == 1 then
        vim.schedule(function()
            api.nvim_buf_set_extmark(scratch.buf, scratch.ns, linenr, get_source_line_length(scratch, linenr), {
                virt_text = { { "=> " .. lines[1], "Comment" } },
            })
        end)
    else
        local virtual_lines = {}
        for _, ln in ipairs(lines) do
            table.insert(virtual_lines, { { ln, "Comment" } })
        end

        vim.schedule(function()
            api.nvim_buf_set_extmark(scratch.buf, scratch.ns, linenr, 0, {
                virt_lines = virtual_lines
            })
        end)
    end
end

local function debug_error(scratch, err)
    local line = get_exec_line(scratch.name, err)
    if line then
        vim.diagnostic.set(scratch.ns, scratch.buf, { {
            col = 0,
            lnum = line - 1,
            message = err:gsub("^" .. vim.pesc(scratch.name) .. ":(%d+):", ""),
            severity = vim.diagnostic.severity.ERROR
        } })
    end
end

local function run(scratch)
local buf = scratch.buf
        api.nvim_buf_clear_namespace(buf, scratch.ns, 0, -1)
        vim.diagnostic.reset(scratch.ns, buf)

        local lines = api.nvim_buf_get_lines(buf, 0, -1, false)


        local chunk, err = loadstring(table.concat(lines, "\n"), "@" .. scratch.name)
        if not chunk then
            debug_error(scratch, err)
            return
        end

        local env = {
            print = function(...) debug_print(scratch, ...) end,
        }
        package.seeall(env)
        setfenv(chunk, env)
        xpcall(chunk, function(e)
            debug_error(scratch, e)
        end)
    end

M = {
    template = {
        "-- Default Defs {{{ vim: ft=lua",
        "local api = vim.api",
        "local fn = vim.fn",
        "local uv = vim.uv",
        "local map = vim.tbl_map",
        "-- }}}", "",
        "--- INFO: Lua Scratch Buffer ---", "", ""
    },
    on_changes = run,
    on_init = function(scratch)
        vim.bo[scratch.buf].filetype = "lua"
    end
}

return M
