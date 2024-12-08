local M = {}
local api = vim.api

local user = vim.env.USER
local function expand_home(path)
    return vim.fn.pathshorten(path:gsub("/tmp/workspaces_" .. user, "~tmp")
        :gsub("/home/" .. user .. "/ws", "~ws")
        :gsub("/home/" .. user .. "/.config", "~cfg")
        :gsub("/home/" .. user, "~"), 6)
end

function M.format_buf_name(buf, short)
    local term_title = vim.b[buf].term_title
    if term_title then
        return term_title, false
    end

    local name = api.nvim_buf_get_name(buf)
    local ft = vim.bo[buf].filetype
    local changed = vim.bo[buf].modified
    local readonly = vim.bo[buf].readonly or not vim.bo[buf].modifiable

    local unnamed = true
    local do_modify = true
    local elems = {}

    if ft == "oil" then
        unnamed = false
        do_modify = false
        if vim.startswith(name, "oil-ssh://") then
            local _, _, host, path = name:find("//([^/]+)/(.*)")
            elems[1] = host .. ":" .. path
        else
            elems[1] = expand_home(name:sub(#"oil://" + 1, -2)) .. "/"
        end
    elseif ft == "qf" then
        return "[qf]"
    elseif ft == "help" then
        return ":h " .. vim.fn.fnamemodify(name, ":t"):gsub("%.txt$", "")
    elseif ft == "fugitive" then
        return "[git]"
    end

    local normal_buf = vim.bo[buf].buftype == ""
    if unnamed and name and name ~= "" then
        unnamed = false
        if normal_buf then
            elems[1] = expand_home(name)
        else
            -- try to get smth reasonable for plugin provided buffers
            elems[1] = vim.fn.fnamemodify(name, ":t")
        end
    end

    if not unnamed then
        if changed then table.insert(elems, "[+]") end
        if readonly then table.insert(elems, "[ro]") end

        if short and do_modify then
            elems[1] = vim.fn.fnamemodify(elems[1], ":t")
        end

        return table.concat(elems, " ")
    end


    return (readonly and "[ro]" or ((changed and normal_buf) and "[~]" or "[-]"))
end

return M
