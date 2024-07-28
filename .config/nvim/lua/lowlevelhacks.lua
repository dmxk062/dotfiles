local M = {}

local ffi = require("ffi")
ffi.cdef [[ 
int64_t write(int fd, void* buf, uint64_t count);
]]


---@param str string
---@param stream integer|nil
---@return boolean success
---write directly to neovims stdout or another specified file
function M.write_raw(str, stream)
    local len = #str
    local bytes = ffi.new("char[?]", len, str)
    local res = ffi.C.write(stream or 1, bytes, len);
    return res > 0
end


return M
