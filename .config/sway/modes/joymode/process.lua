local M = {}

local uv = require("luv")

---@param program string
---@param args string[]
---@return string[] output
---@return integer exitcode
function M.get_program_output(program, args)
    local pipe = uv.new_pipe()
    local output = {}
    local exitc = 0

    local done = false

    local handle, pid = uv.spawn(program, {
        args = args,
        stdio = { nil, pipe }
    }, function(code, signal)
        exitc = code
        done = true
    end)

    pipe:read_start(function(err, data)
        assert(not err, err)
        if data then
            output[#output+1] = data
        end
    end)

    while not done do
        uv.run("once")
    end

    uv.close(handle)

    return output, exitc
end

return M
