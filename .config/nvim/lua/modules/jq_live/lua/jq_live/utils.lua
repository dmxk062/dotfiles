local M = {}

function M.get_region(opts)
    if opts.range == 2 then
        return { opts.line1, opts.line2 }
    else
        return { 1, vim.api.nvim_buf_line_count(0) }
    end
end

return M
