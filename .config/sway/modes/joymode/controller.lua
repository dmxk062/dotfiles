local ffi = require("ffi")
local uv = require("luv")

local util = require("process")

ffi.cdef [[
struct js_event {
    uint32_t time;
    int16_t value;
    uint8_t type;
    uint8_t number;
};

int open(const char* path, int flags);
ssize_t read(int fd, void* buf, size_t count);
int ioctl(int fd, unsigned int req, ...);
]]

local JS_EVENT_SIZE = ffi.sizeof("struct js_event")
---@cast JS_EVENT_SIZE integer

local event_type = {
    button = 0x01,
    axis   = 0x02,
    init   = 0x03,
}

local btn_names = {
    [0x130] = "B",
    [0x131] = "A",
    [0x132] = "C",
    [0x133] = "X",
    [0x134] = "Y",
    [0x136] = "SL",
    [0x137] = "SR",
    [0x138] = "BL",
    [0x139] = "BR",
    [0x13A] = "-",
    [0x13B] = "+",
    [0x13C] = "Home",
    [0x222] = "L",
    [0x220] = "U",
    [0x221] = "D",
    [0x223] = "R",
    [0x13D] = "LStick",
    [0x13E] = "RStick",
}

local named_btns = {}
for k, v in pairs(btn_names) do
    named_btns[v] = k
end

local ioctls = {
    get_btn_map = 0x84006a34, -- got manually == _IOR('j', 0x34, u16[KEY_MAX - BTN_MISC + 1])
}

---@alias JSEvent {time: integer, value: integer, type: integer, number: integer}

---@class Leds
---@field files integer[]
---@field max integer[]
---@field set fun(self: Leds, states: boolean[])
---@field get fun(self: Leds): boolean[]

---@class Controller
---@field fd integer
---@field ev JSEvent
---@field evmap table<integer, integer>
---@field pressed table<string, boolean?>
---@field axes {r: [integer, integer], l: [integer, integer]}
---@field num_pressed integer
---@field devpath string
---@field leds Leds
local Controller = {}
Controller_meta = {
    __index = function(t, k)
        return Controller[k]
    end
}

---@return table<integer, integer>?, integer?
function Controller:get_btn_map()
    local buffer = ffi.new("uint16_t[512]")
    local ret = ffi.C.ioctl(self.fd, ioctls.get_btn_map, buffer)
    if ret < 0 then
        return nil, ffi.errno()
    end

    local map = {}

    for i = 0, 511 do
        local code = buffer[i]
        map[i] = code
    end

    return map
end

function Controller:get_leds()
    local ledpath = self.devpath .. "/device/device/leds"

    local dir = uv.fs_opendir(ledpath)
    local ent = uv.fs_readdir(dir)
    local available_leds = {}

    while ent do
        if ent[1].type == "directory" then
            table.insert(available_leds, ent[1].name)
        end
        ent = uv.fs_readdir(dir)
    end
    uv.fs_closedir(dir)

    table.sort(available_leds, function(l1, l2)
        local o1 = tonumber(l1:match("%d+$"))
        local o2 = tonumber(l2:match("%d+$"))

        return o1 < o2
    end)

    local brightness_fds = {}
    local max_values = {}
    for _, led in ipairs(available_leds) do
        local path = ledpath .. "/" .. led
        local fd, err = uv.fs_open(path .. "/brightness", "r+", 0)
        assert(fd, err)
        table.insert(brightness_fds, fd)

        local max_bright_file, err = io.open(path .. "/max_brightness")
        assert(max_bright_file, err)
        local max_bright  = max_bright_file:read("*a"):gsub("%s*$", "")
        table.insert(max_values, max_bright)
        max_bright_file:close()
    end

    ---@type Leds
    return {
        files = brightness_fds,
        max = max_values,
        set = function(inst, values)
            for i, led in ipairs(inst.files) do
                if values[i] then
                    uv.fs_write(led, inst.max[i])
                else
                    uv.fs_write(led, "0")
                end
            end
        end,
        get = function(inst)
            local out = {}
            for i, led in ipairs(inst.files) do
                local bright = uv.fs_read(led, 4):gsub("%s*$", "")
                out[i] = bright ~= "0"
            end

            return out
        end
    }
end

---@return Controller?, integer?
function Controller.new(dev)
    local fd, err = uv.fs_open("/dev/input/" .. dev, 0, 0)
    if not fd then
        return nil, ffi.errno()
    end

    local obj = setmetatable({
        fd = fd,
    }, Controller_meta)

    local evmap, err = obj:get_btn_map()
    if not evmap then
        return nil, err
    end

    obj.evmap = evmap

    local output, err = util.get_program_output("udevadm", {
        "info", "--query=property", "--property=DEVPATH",
        "--name=/dev/input/" .. dev })

    if err > 0 then
        return nil, err
    end
    
    obj.devpath = "/sys" .. output[1]:gsub("%s*$", ""):sub(#"DEVPATH="+1)

    obj.leds = obj:get_leds()

    return obj
end

---@param cb fun(con: Controller, event: "button"|"axis", info: table): boolean
function Controller:start_listen(cb)
    self.pressed = {}
    self.axes = { l = { 0, 0 }, r = { 0, 0 } }
    self.num_pressed = 0
    local function on_read(err, data)
        if err then
            error(err)
        end

        ---@type JSEvent
        local ev = ffi.new("struct js_event")
        ffi.copy(ev, data, JS_EVENT_SIZE)
        self.ev = ev
        local typ = ev.type

        local info
        if typ == event_type.button then
            local btn = self.evmap[self.ev.number]
            local name = btn_names[btn]
            local is_pressed = ev.value == 1

            info = { name, is_pressed }
            self.pressed[name] = is_pressed and true or nil

            if is_pressed then
                self.num_pressed = self.num_pressed + 1
            else
                self.num_pressed = self.num_pressed - 1
            end

        elseif typ == event_type.axis then
            local axnum = ev.number
            if axnum == 0 then
                self.axes.l[1] = ev.value
            elseif axnum == 1 then
                self.axes.l[2] = ev.value
            elseif axnum == 2 then
                self.axes.r[1] = ev.value
            else
                self.axes.r[2] = ev.value
            end
        end

        if not cb(self, typ == event_type.button and "button" or "axis", info) then
            return
        end

        uv.fs_read(self.fd, JS_EVENT_SIZE, nil, on_read)
    end
    uv.fs_read(self.fd, JS_EVENT_SIZE, nil, on_read)
end

return {
    Controller = Controller
}
