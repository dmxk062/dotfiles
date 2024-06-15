local plugin = {}
local U = require("jq_live.utils")
local view = require("jq_live.view")
local J = require("jq_live.jq")


function plugin.live_query(buf, start_line, end_line)
    return view.live_query(buf, start_line, end_line, M.opts.live_query)
end

local function with_defaults(opts)
    return vim.tbl_deep_extend("force", {
        jq = {
            program = "jq",
        },
        live_query = {
            height = 0.66,
            ratio  =  0.33,
            input_title = "Query Input",
            output_title = "Query Output",
            callback = function (bu, bi, bo) end,
            winopts = {
                style = "minimal",
                border = "rounded",
            },
        },
        result = {
            title = "Query Output",
            height = 0.8,
            width = 0.8,
            winopts = {
                style = "minimal",
                border = "rounded",
            }
        }
    }, opts)
end

function plugin.setup(opts)
    M.opts = with_defaults(opts)

    if not vim.fn.executable(M.opts.jq.program) then
        vim.notify("Please make sure `" .. M.opts.jq.program .. "` is executable.", vim.log.levels.ERROR)
        return false
    end

    vim.api.nvim_buf_create_user_command(0, "Jq", function(cmd_opts)
        local lines = U.get_region(cmd_opts)
        local filtered, err = J.jq_query_lines(0, lines[1], lines[2], cmd_opts.fargs)
        if err then
            vim.notify(err, vim.log.levels.ERROR)
        elseif filtered and #filtered > 0 then
            vim.api.nvim_buf_set_lines(0, lines[1] - 1, lines[2], false, filtered)
        end
    end, {
        nargs = "*",
        range = 2,
    })
    vim.api.nvim_buf_create_user_command(0, "JqQuery", function(cmd_opts)
        local lines = U.get_region(cmd_opts)
        if #cmd_opts.fargs ~= 0 then
            local filtered, err = J.jq_query_lines(0, lines[1], lines[2], cmd_opts.fargs)
            if err then
                vim.notify(err, vim.log.levels.ERROR)
                return
            end
            if filtered then
                view.show_query_output(filtered, M.opts.result)
            end
        else
            plugin.live_query(vim.api.nvim_get_current_buf(), lines[1], lines[2])
        end
    end, {
        nargs = "*",
        range = 2,
    })
end


return plugin
