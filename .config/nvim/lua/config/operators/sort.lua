local numeric_sort = function(x, y)
    local xnumeric = x:match("^[+-]?%d*%.?%d+")
    local ynumeric = y:match("^[+-]?%d*%.?%d+")
    -- sort alphabetic
    local xnum = xnumeric and tonumber(xnumeric) or nil
    local ynum = ynumeric and tonumber(ynumeric) or nil
    if (not xnum) and (not ynum) then
        -- fall back to alphabetic comparisons
        return x < y
    end

    -- sort pure text at the end of the list
    return (xnum or math.huge) < (ynum or math.huge)
end

local alphabetic_sort = function(x, y)
    return x < y
end

local length_sort = function(x, y)
    return vim.fn.strdisplaywidth(x) < vim.fn.strdisplaywidth(y)
end

local sort_methods = {
    alphabetic = alphabetic_sort,
    length = length_sort,
    numeric = numeric_sort,
}

---@param str string
---@return string[] split
---@return string delimiter
local intelligent_split = function(str)
    if str:find(",", 1, true) then
        return vim.split(str, ",", { plain = true }), ","
    elseif str:find(";", 1, true) then
        return vim.split(str, ";", { plain = true }), ";"
    else
        return vim.split(str, "%s"), " "
    end
end

---@type config.op.cb
local sort_operator = function(mode, region, extra, get, set)
    local args = extra.arg or {}
    local split, delimiter
    if mode == "char" then
        local content = table.concat(get(), "")
        split, delimiter = intelligent_split(content)
    else
        split = get()
    end

    local no_whiteonly = vim.tbl_filter(function(v)
        return not v:match("^%s*$")
    end, split)

    local to_sort = {}
    local starting_whitespace = {}
    local ending_whitespace = {}
    for i, val in ipairs(no_whiteonly) do
        -- try to preserve whitespace (e.g. indent)
        -- as best as possible
        starting_whitespace[i], to_sort[i], ending_whitespace[i]
        = val:match("^(%s*)(.-)(%s*)$")
    end
    local sort_fun
    if args.method and sort_methods[args.method] then
        sort_fun = sort_methods[args.method]
    elseif to_sort[1]:match("^[+-]?%d*%.?%d+") then
        sort_fun = numeric_sort
    else
        sort_fun = alphabetic_sort
    end

    table.sort(to_sort, function(x, y)
        if args.reverse then
            return sort_fun(y, x)
        else
            return sort_fun(x, y)
        end
    end)
    local sorted = {}
    for i, val in ipairs(to_sort) do
        table.insert(sorted, starting_whitespace[i] .. val .. ending_whitespace[i])
    end

    local output
    if mode == "char" then
        output = { table.concat(sorted, delimiter) }
    else
        output = sorted
    end

    set(region, output)
end

return sort_operator
