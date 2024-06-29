local M = {}

---@param col1 string
---@param col2 string
---@param alpha decimal
function M.blend(col1, col2, alpha)
    local r1, g1, b1 = tonumber(col1:sub(2,3), 16), tonumber(col1:sub(4,5), 16), tonumber(col1:sub(6,7), 16)
    local r2, g2, b2 = tonumber(col2:sub(2,3), 16), tonumber(col2:sub(4,5), 16), tonumber(col2:sub(6,7), 16)

    local rr = math.floor((r1 * alpha) + (r2 * (1-alpha)))
    local gr = math.floor((g1 * alpha) + (g2 * (1-alpha)))
    local br = math.floor((b1 * alpha) + (b2 * (1-alpha)))

    return string.format("#%02X%02X%02x", rr, gr, br)
end

return M
