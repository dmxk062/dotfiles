local oil = require("oil")
local icons = require("nvim-web-devicons")

local hl_prefix = "StartScreenShortcut"

local const_pad = {
    v=16,
    h=16
}

local const_max = {
    v=80,
    h=64
}
local function button(text, hl, bind, callback, width, texthl)
    local opts = {
        position = "center",
        shortcut = bind,
        cursor   = 3,
        width    = width + (const_pad.v - 8),
        align_shortcut = "right",
        hl_shortcut =  hl,
        hl = texthl or hl,

        keymap = {"n", bind, callback}
    }

    return {
        type = "button",
        val = " " .. text,
        on_press = callback,
        opts = opts
    }
end


local function nice_names(path, user, max_length)
    local full = path:gsub("/tmp/workspaces_" .. user, "~tmp")
    :gsub("/home/" .. user .. "/ws", "~ws")
    :gsub("/home/" .. user .. "/.config", "~cfg")
    :gsub("/home/" .. user, "~")

    if full:sub(-1, -1) == "/" and #full > 1 then
        full = full:sub(0, -2)
    end


    local short
    if #full > max_length then
        local elems = vim.split(full, "/")
        -- path might start at /
        if full:sub(1,1) == "/" then
            short = "/" .. elems[2] .. "/.../" .. elems[#elems]
        else 
            short = elems[1] .. "/.../" .. elems[#elems]
        end
    else 
        short = full
    end

    return short
end


local function get_extension(fn)
    local match = fn:match("^.+(%..+)$")
    local ext = ""
    if match ~= nil then
        ext = match:sub(2)
    end
    return ext
end

function get_icon(file)
    local ext = get_extension(file)
    local ico, hl = icons.get_icon(file, ext, { default = true})
    local new_hl = {}
    table.insert(new_hl, {hl, 0, 2})
    return ico, new_hl
end

local function get_key_for_i(i)
    if i < 11 then
        return tostring(i - 1)
    else 
        return ',' .. i - 1
    end
end

local function generate_old_file_list(maxfiles, max_width)
    local user = os.getenv("USER") or "dmx"
    local oldfiles = {}

    -- might not be loaded yet
    vim.cmd.rshada()
    for _, f in pairs(vim.v.oldfiles) do
        if #oldfiles > maxfiles then
            break
        end
        if vim.startswith(f, "oil://") then
            local name = f:sub(#"oil://" + 1)
            table.insert(oldfiles, {name=nice_names(name, user, max_width), path=name, ico="󰉋 ", hl="Files", dir=true})
        elseif not vim.startswith(f, "oil-ssh://") then
            if vim.fn.filereadable(f) == 0 then
                goto continue
            end
            ico, hl = get_icon(f)
            table.insert(oldfiles, {name=nice_names(f, user, max_width), path=f, ico=ico, hl=hl, dir=false})
        end
        ::continue::
    end

    local buttons = {}

    for i, file in ipairs(oldfiles) do
        if file.dir then
            local button = button(file.ico .. file.name,
                "Number",
                get_key_for_i(i),
                function() oil.open(file.path) end,
                max_width,
                hl_prefix .. "Dir"
            )
            table.insert(buttons, button)
        else

            local button = button(file.ico .. " " .. file.name,
                "Number",
                get_key_for_i(i),
                function() vim.cmd.edit(file.path) end,
                max_width,
                file.hl
            )
            table.insert(buttons, button)
        end
    end


    return buttons
end

local header = {
    type = "text",
    val = {
        [[ _        _______  _______          _________ _______ ]],
        [[( (    /|(  ____ \(  ___  )|\     /|\__   __/(       )]],
        [[|  \  ( || (    \/| (   ) || )   ( |   ) (   | () () |]],
        [[|   \ | || (__    | |   | || |   | |   | |   | || || |]],
        [[| (\ \) ||  __)   | |   | |( (   ) )   | |   | |(_)| |]],
        [[| | \   || (      | |   | | \ \_/ /    | |   | |   | |]],
        [[| )  \  || (____/\| (___) |  \   /  ___) (___| )   ( |]],
        [[|/    )_)(_______/(_______)   \_/   \_______/|/     \|]],
    },

    opts = {
        position = "center",
        hl = (function(count)
            local hls = {}
            for i = 1, count do
                hls[i] = {{"StartScreenTitle" .. i, 0, -1}}
            end
            return hls
        end)(9)
    }
}

local shortcuts = {
    type = "group",
    val = (function()
        local max_width = math.min(vim.api.nvim_win_get_width(0) - const_pad.h, const_max.h)
        return {
            button("󰉋 View and Edit Files", hl_prefix .. "Files", "f", oil.open, max_width),
            button("󰱼 Search Files",
                hl_prefix .. "Search",
                ",/", 
                function() require("telescope.builtin").find_files{layout_config = {height = .6}} end,
                max_width
            ),

            button("󱎸 Grep Files",
                hl_prefix .. "Grep",
                ",g", 
                function() require("telescope.builtin").live_grep{layout_config = {height = .6}} end,
                max_width
            ),
            button("󰋚 Search History",
                hl_prefix .. "History",
                ",h", 
                function() require("telescope.builtin").oldfiles{layout_config = {height = .6}} end,
                max_width
            ),
        }
    end)()
}

local history = {
    type = "group",
    val = generate_old_file_list(
        -- math.min(vim.api.nvim_win_get_height(0) + 46),
        100,
        math.min(vim.api.nvim_win_get_width(0) - const_pad.h, const_max.h)
    ),
}




require("alpha").setup{
    layout = {
        header,
        {type = "padding", val = 2},
        shortcuts,
        {type = "padding", val = 1},
        history,
    },
    opts = {
        margin = 4,
        setup = function()
            vim.wo.cursorline = true
            vim.wo.cursorlineopt = "line"
            vim.wo.number = false
            vim.wo.signcolumn = "no"
        end
    }
}
