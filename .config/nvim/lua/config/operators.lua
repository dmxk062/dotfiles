local M = {}

local Ctx = {
    funs = { },
    extra_data = {},
    was_repeat = {},
    cb = nil,
    -- HACK: preserve last cursor before going into O-pending mode
    last_cursor = nil,

}

local function get_mark(mark)
    return vim.api.nvim_buf_get_mark(0, mark)
end

local function get_op_region(mode)
    if mode == "visual" then
        return { get_mark "<", get_mark ">" }
    else
        return { get_mark "[", get_mark "]" }
    end
end

function M.opfunc(mode)
    Ctx.funs[Ctx.cb](mode)
end

---@alias point [integer, integer]
---@alias region [point, point]
---@alias op_extra {saved: table, repeated: boolean}
---@alias op_function fun(mode: string, region: region, extra: op_extra, get: fun(mode: string?): string[]): string[]?, point?, point?

---@param name string
---@param cb function
function M.make_operator(name, cb)
    local function operator(mode)
        local is_repeat = true
        if mode == nil then
            Ctx.cb = name
            Ctx.was_repeat[name] = false
            vim.o.operatorfunc = "v:lua.require'config.operators'.opfunc"
            return "g@"
        elseif not Ctx.was_repeat[name] then
            Ctx.was_repeat[name] = true
            is_repeat = false
        end
        local region = get_op_region(mode)
        local function get_content(_mode)
            local m = _mode or mode
            if m == "line" then
                return vim.api.nvim_buf_get_lines(0, region[1][1]-1, region[2][1], false)
            else
                return vim.api.nvim_buf_get_text(0, region[1][1]-1, region[1][2], region[2][1]-1, region[2][2] + 1, {})
            end
        end

        if not Ctx.extra_data[name] then
            Ctx.extra_data[name] = {}
        end
        ---@type op_extra
        local extra = {
            saved = Ctx.extra_data[name],
            repeated = is_repeat,
        }
        local replacement, startpos, endpos = cb(mode, region, extra, get_content)
        if replacement then
            if mode == "line" then
                vim.api.nvim_buf_set_lines(0, startpos[1] - 1, endpos[1], false, replacement)
            else
                vim.api.nvim_buf_set_text(0, startpos[1] - 1, startpos[2], endpos[1] - 1, endpos[2] + 1, replacement)
            end
        end
    end

    Ctx.funs[name] = operator
    return operator
end

--- Maps a function as a visual and normal mode operator
---@param keys string
---@param cb op_function
---@param opts {normal_only: boolean?, desc: string?}?
function M.map_function(keys, cb, opts)
    opts = opts or {}
    mapopts = {
        expr = true,
        desc = opts.desc
    }
    local id = keys .. "_operator"
    local operator = M.make_operator(id, cb)
    -- use last char of string to indicate repeat for one line
    local repeat_char = keys:sub(-1, -1)

    if not opts.normal_only then
        vim.keymap.set("x", keys, operator, mapopts)
    end
    vim.keymap.set("n", keys, operator, mapopts)
    vim.keymap.set("n", keys .. repeat_char, function()
        operator()
        return "g@Vl"
    end, mapopts)
end

return M
