-- utilities for json files
-- mainly based on jq

local function jq_filter(lines, expr)
    local result = {}

    local cmd = vim.list_extend(
        {"jq", "--indent", tostring(vim.o.tabstop),
        "--argjson", "FILE", string.format([["%s"]], vim.fn.expand("%")),
        },
    expr or {})

    local res = vim.system(cmd, {
        stdin = lines,
    }):wait()

    if res.code > 0 then
        vim.notify(res.stderr, vim.log.levels.ERROR)
        return nil
    end

    result = vim.split(res.stdout, "\n")

    if #result == 0 then
        return nil
    else
        return result
    end
end

local function jq_filter_buffer_or_lines(opts)
    local start_line, end_line

    -- selection
    if opts.range == 2 then
        start_line = opts.line1
        end_line = opts.line2
    else
        start_line = 1
        end_line = vim.api.nvim_buf_line_count(0)
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local filtered = jq_filter(lines, opts.fargs or {})

    if filtered then
        vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, filtered)
    end

end


vim.api.nvim_buf_create_user_command(0, "Jq", jq_filter_buffer_or_lines,{
    nargs = "*",
    range = 2,
    complete = function (ArgLead, CmdLine, CursorPos)
        return {"-r", "-c", "length"}
    end
})
