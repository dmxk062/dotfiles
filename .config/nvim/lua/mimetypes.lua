local M = {}
local ffi = require("ffi")

ffi.cdef [[
typedef struct magic_set* magic_t;
magic_t magic_open(int flags);
int magic_load(magic_t ms, const char* filename);
const char* magic_file(magic_t ms, const char* filename);
const char* magic_error(magic_t ms);
void magic_close(magic_t ms);
]]
local MAGIC= {
    MIMETYPE = 0x0000010,
    ERROR    = 0x0000200,
}


local magic = ffi.load("magic")

-- initialize magic database only on first require
-- error is necessary so magic_file() doesnt just directly output the error
M.magic = magic.magic_open(bit.bor(MAGIC.MIMETYPE, MAGIC.ERROR))
magic.magic_load(M.magic, nil);

---gets the mimetype of a file using libmagic
---@param file string
---@return string? mimetype nil if error
---@return string? error_msg string if error
function M.get_mime(file)
    local res = magic.magic_file(M.magic, file)

    -- magic returned an error
    if res == nil then
        return nil, ffi.string(magic.magic_error(M.magic))
    end

    local str = ffi.string(res)


    -- return mimetype
    return str
end

-- close the magic file when table is no longer used
local gc_table = {
    __gc = function()
        magic.magic_close(M.magic)
    end
}
setmetatable(M, gc_table)

return M
