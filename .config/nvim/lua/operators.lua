local M = {}

M.Ctx = {
    funs = {

    },
    cb = nil
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
    M.Ctx.funs[M.Ctx.cb](mode)
end

---@alias op_point {[1]: integer, [2]: integer}
---@alias op_region {[1]: op_point, [2]: op_point}

---@alias op_function fun(mode: string, region: op_region, get: fun(mode: string?): string[]): string[]?, op_point?, op_point?

---@param name string
---@param cb function
function M.make_operator(name, cb)
    local function operator(mode)
        if mode == nil then
            M.Ctx.cb = name
            vim.o.operatorfunc = "v:lua.require'operators'.opfunc"
            return "g@"
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
        local replacement, startpos, endpos = cb(mode, region, get_content)
        if replacement then
            if mode == "line" then
                vim.api.nvim_buf_set_lines(0, startpos[1] - 1, endpos[1], false, replacement)
            else
                vim.api.nvim_buf_set_text(0, startpos[1] - 1, startpos[2], endpos[1] - 1, endpos[2] + 1, replacement)
            end
        end
    end

    M.Ctx.funs[name] = operator
    return operator
end

--- Maps a function as a visual and normal mode operator
---@param keys string
---@param cb op_function
function M.map_function(keys, cb)
    local id = keys .. "_operator"
    local operator = M.make_operator(id, cb)
    -- use last char of string to indicate repeat for one line
    local repeat_char = keys:sub(-1, -1)

    vim.keymap.set({ "x", "n" }, keys, operator, { expr = true })
    vim.keymap.set({ "n" }, keys .. repeat_char, function()
        operator()
        return "g@Vl"
    end, { expr = true })
end

return M
