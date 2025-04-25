local api = vim.api

---@type config.overlay
---@diagnostic disable-next-line: missing-fields
local M = {
    name = "objdump",
    writeable = false,
    state = {},
}

M.attach = function(wbuf, dbuf)
    local name = api.nvim_buf_get_name(wbuf)
    local job = vim.system({ "objdump", "-d", name }, {}):wait()
    if job.code ~= 0 then
        vim.notify("[Overlay] " .. job.stderr, vim.log.levels.ERROR)
        return false
    end

    api.nvim_buf_set_lines(dbuf, 0, -1, false, vim.split(job.stdout, "\n", { plain = true }))
    vim.bo[dbuf].filetype = "objdump"
    vim.bo[dbuf].modifiable = false
    api.nvim_buf_set_name(dbuf, name .. ":elf")
    api.nvim_exec_autocmds("BufWinEnter", {
        buffer = dbuf
    })
    return true
end

M.detach = function(wbuf, dbuf)
end

return M
