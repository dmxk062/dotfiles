local M = {}

--[[
Show git status of a file as virtual text
]]

local api = vim.api
local oil = require("oil")
local ns = api.nvim_create_namespace("config.oil.git")

local buffer_status = {}

local hl_for_status = {
    ["!"] = "Ignored",
    ["?"] = "Untracked",
    ["A"] = "Added",
    ["C"] = "Copied",
    ["D"] = "Deleted",
    ["M"] = "Modified",
    ["R"] = "Renamed",
    ["T"] = "TypeChanged",
    ["U"] = "Unmerged",
    [" "] = "Unmodified",
}

local function set_signs(buf, status)
    buffer_status[buf] = status
    api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    if not status then
        return
    end

    for i = 1, api.nvim_buf_line_count(buf) do
        local ent = oil.get_entry_on_line(buf, i)
        if not ent then
            goto continue
        end
        local name = ent.name

        local codes = status[name] or { " ", "!" }

        local worktree = codes[1]
        local index = codes[2]
        api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
            end_col = 0,
            end_line = i - 1,
            virt_text = {
                { worktree, "OilGitStatusWorktree" .. hl_for_status[worktree] },
                { index,    "OilGitStatusIndex" .. hl_for_status[index] },
                { " " }
            },
            virt_text_pos = "inline",
        })

        ::continue::
    end
end

local function async_at_once(funcs, cb, ...)
    local count = 0
    local results = {}
    for i, fn in ipairs(funcs) do
        fn(function(res)
            count = count + 1
            results[i] = res

            if count == #funcs then
                cb(results)
            end
        end, ...)
    end
end

local function get_git_status(cb, dir)
    vim.system(
        { "git", "-c", "core.quotepath=false", "-c", "status.relativePaths=true", "status", ".", "--short" },
        { cwd = dir, },
        function(out)
            if out.code ~= 0 then
                return
            end

            local status = {}
            for line in vim.gsplit(out.stdout, "\n") do
                if line == "" then
                    goto continue
                end
                if line:sub(-1, -1) == "/" then
                    line = line:sub(1, -2)
                end

                local index = line:sub(1, 1)
                local worktree = line:sub(2, 2)
                local file = line:sub(4)

                local dirstart = file:find("/")

                if dirstart then
                    file = file:sub(1, dirstart - 1)
                    if not status[file] then
                        status[file] = { index == "?" and " " or index, worktree }
                    else
                        if index ~= " " and index ~= "?" then
                            status[file][1] = "M"
                        end
                        if worktree ~= " " then
                            status[file][2] = "M"
                        end
                    end
                else
                    if index == "R" then
                        status[vim.split(file, " -> ")[2]] = { "R", " " }
                    else
                        status[file] = { index, worktree }
                    end
                end

                ::continue::
            end
            cb(status)
        end)
end

local function get_git_unchanged(cb, dir)
    vim.system(
        { "git", "-c", "core.quotepath=false", "ls-tree", "HEAD", ".", "--name-only" },
        { cwd = dir },
        function(out)
            if out.code ~= 0 then
                return
            end

            local status = {}
            for line in vim.gsplit(out.stdout, "\n") do
                if line == "" then
                    goto continue
                end

                status[line] = { " ", " " }
                ::continue::
            end

            cb(status)
        end)
end

local function update_buf(buf)
    local dir = require("oil").get_current_dir(buf)
    if not dir then
        return
    end

    async_at_once({
            get_git_status,
            get_git_unchanged,
        },
        vim.schedule_wrap(function(results)
            local merged = vim.tbl_extend("keep", results[1], results[2])
            set_signs(buf, merged)
        end),
        dir
    )
end

M.attach = function(buf)
    if buffer_status[buf] then
        return
    end

    buffer_status[buf] = true

    local group = api.nvim_create_augroup("config.oil.git#" .. buf, { clear = true })
    api.nvim_create_autocmd("BufDelete", {
        buffer = buf,
        group = group,
        callback = function()
            buffer_status[buf] = nil
            api.nvim_del_augroup_by_id(group)
        end
    })

    api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
        buffer = buf,
        group = group,
        callback = function()
            update_buf(buf)
        end
    })

    api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
        buffer = buf,
        group = group,
        callback = function()
            if buffer_status[buf] and buffer_status[buf] ~= true then
                set_signs(buf, buffer_status[buf])
            end
        end
    })

    api.nvim_create_autocmd("User", {
        pattern = "FugitiveChanged",
        group = group,
        callback = function()
            update_buf(buf)
        end
    })

    api.nvim_create_autocmd("User", {
        pattern = "GitSignsUpdate",
        group = group,
        callback = function()
            update_buf(buf)
        end
    })

    update_buf(buf)
end

return M
