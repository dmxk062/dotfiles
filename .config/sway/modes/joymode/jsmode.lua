#!/usr/bin/env luajit

local ydotool = require("ydotool")
local uv = require("luv")

local controller, err = require("controller").Controller.new(arg[1])
if not controller then
    error("Failed to open " .. arg[1] .. " as a controller: errno=" .. err)
end

ydotool.init()
local led_save = controller.leds:get()

local function on_shutdown()
    controller.leds:set(led_save)
    ydotool.release_all()
end

local function scale_mouse(val)
    local range = (val / 32768)
    local abs = math.abs(range)
    local isneg = range < 0

    if abs > 0.8 then
        return math.floor(range * 4)
    elseif abs > 0.4 then
        return math.floor(range * 3)
    else
        return (isneg and -1 or 1)
    end
end

local mode = "raw"

local mappings = {
    default = {
        leds = { true, false, false, true },
        buttons = {
            ["X"] = { "press", "MouseLeft" },
            ["Y"] = { "press", "MouseRight" },
            ["L"] = { "press", "KeyLeft" },
            ["D"] = { "press", "KeyDown" },
            ["U"] = { "press", "KeyUp" },
            ["R"] = { "press", "KeyRight" },
            ["RStick"] = { "press", "MouseMiddle" },
        },

        chords = {
            [{ "Home", "+" }] = { "mode", "media" },
            [{ "Home", "D" }] = { "mode", "raw" },
            [{ "Home", "SL", "SR" }] = { "func", function()
                on_shutdown()
                os.exit(1)
            end }
        }
    },

    media = {
        leds = { false, true, false, false },
        buttons = {
            ["Home"] = { "mode", "default" },
            ["L"] = { "press", "MediaPrev" },
            ["R"] = { "press", "MediaNext" },
            ["U"] = { "press", "VolumeUp" },
            ["D"] = { "press", "VolumeDown" },
            ["+"] = { "press", "MediaPlay" },
            ["SL"] = { "press", { "Shift", "MediaPrev" } },
            ["SR"] = { "press", { "Shift", "MediaNext" } },
        },

        chords = {}
    },

    raw = {
        leds = { true, false, false, false },
        buttons = {},
        chords = {
            [{ "Home", "+", "X" }] = { "mode", "default" }
        }
    }
}

local function do_press(button, state)
    if type(button) == "string" then
        button = ydotool.buttons[button]
    elseif type(button) == "table" then
        for _, btn in ipairs(button) do
            do_press(btn, state)
        end
        return
    end
    ydotool.set_button(button, state, true)
end

local actions = {
    press = function(cfg, con, state)
        do_press(cfg[2], state)
    end,
    mode = function(cfg, con, state)
        if state then
            mode = cfg[2]
            con.leds:set(mappings[mode].leds)
        end
    end,
    func = function(cfg, con, state)
        cfg[2](cfg, con, state)
    end
}

local function chord_is_pressed(chord, pressed)
    for _, btn in pairs(chord) do
        if not pressed[btn] then
            return false
        end
    end

    return true
end

controller.leds:set(mappings[mode].leds)

controller:start_listen(function(con, event, info)
    if event == "button" then
        if con.num_pressed == 1 then
            local press_map = mappings[mode].buttons[info[1]]
            if press_map then
                actions[press_map[1]](press_map, con, info[2])
                goto done
            end
        end

        if info[2] then
            for chord, mapping in pairs(mappings[mode].chords) do
                if chord_is_pressed(chord, con.pressed) then
                    actions[mapping[1]](mapping, con, info[2])
                end
            end
        end
    end

    ::done::
    return true
end)

local mouse_timer = uv.new_timer()
local laxis = controller.axes.l
local raxis = controller.axes.r
local mcounter = 0
uv.timer_start(mouse_timer, 100, 3, function()
    if mode == "raw" then
        return
    end

    if laxis[1] ~= 0 then
        ydotool.emit_event(2, 0, scale_mouse(laxis[1]), true)
    end
    if laxis[2] ~= 0 then
        ydotool.emit_event(2, 1, scale_mouse(laxis[2]), true)
    end

    if mcounter % 3 == 0 then
        if raxis[1] ~= 0 then
            ydotool.emit_event(2, 6, scale_mouse(raxis[1]), true)
        end
        if raxis[2] ~= 0 then
            ydotool.emit_event(2, 8, -scale_mouse(raxis[2]), true)
        end
    end

    mcounter = mcounter + 1
end)



local signal = uv.new_signal()
uv.signal_start(signal, "sigint", function(sig)
    on_shutdown()
    os.exit(1)
end)

uv.run()
