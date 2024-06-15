local M = {}

function M.jq_filter(lines, expr)
    local result = {}

    local cmd = vim.list_extend(
        { "jq", "--indent", tostring(vim.o.tabstop),
        },
        expr or {})

    local res = vim.system(cmd, {
        stdin = lines,
    }):wait()

    if res.code > 0 then
        return nil, res.stderr
    end

    result = vim.split(res.stdout, "\n")

    return result
end

function M.jq_query_lines(buf, start_line, end_line, query)
    local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
    return M.jq_filter(lines, query or {})
end

return M
