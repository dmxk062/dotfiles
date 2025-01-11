local M = {}

local ffi = require("ffi")
local uv = require("luv")
local buf = require("string.buffer")
local socket = require("posix.sys.socket")

local socket_path = os.getenv("YDOTOOL_SOCKET") or ("/run/user/" .. uv.getuid() .. "/.ydotool_socket")

local ydotool_socket

function M.init()
    local sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM, 0)
    socket.connect(sock, { family = socket.AF_UNIX, path = socket_path })


    ydotool_socket = sock
end

ffi.cdef [[
struct input_event {
    uint64_t secs;
    uint64_t nsecs;
    uint16_t type;
    uint16_t code;
    int32_t value;
};
]]


local INPUT_EVENT_SIZE = ffi.sizeof("struct input_event")
---@cast INPUT_EVENT_SIZE integer

local _SYN_EVENT = buf.new(24)
_SYN_EVENT:putcdata(ffi.new("struct input_event", { type = 0, code = 0, value = 0}), INPUT_EVENT_SIZE)
local SYN_EVENT = tostring(_SYN_EVENT)

---@alias InputEvent {type: integer,  code: integer, value: integer}

function M.emit_event(type, code, value, syn)
    local b = buf.new(48)
    local ev = ffi.new("struct input_event", { type = type, code = code, value = value })
    b:putcdata(ev, INPUT_EVENT_SIZE)
    socket.send(ydotool_socket, tostring(b))

    if syn then
        socket.send(ydotool_socket, SYN_EVENT)
    end
end


M.buttons = {
    Shift = 42,
    Control = 29,
    Alt = 56,
    Super = 125,

    MouseLeft = 0x110,
    MouseRight = 0x111,
    MouseMiddle = 0x112,

    KeyLeft = 105,
    KeyUp = 103,
    KeyDown = 108,
    KeyRight = 106,

    MediaPlay = 164,
    MediaNext = 163,
    MediaPrev = 165,
    VolumeDown = 114,
    VolumeUp = 115,
}

M.pressed = {}

---@param button integer
---@param state boolean
---@param syn? boolean
function M.set_button(button, state, syn)
    if state then
        M.pressed[button] = true
    else
        M.pressed[button] = nil
    end

    M.emit_event(1, button, state and 1 or 0, syn)
end

function M.release_all()
    for k, _ in pairs(M.pressed) do
        M.set_button(k, false)
    end
end

return M
