local M = {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
}

M.opts = {}

function M.config(_, opts)
    local mc = require("multicursor-nvim")
    mc.setup(opts)

    local map = require("config.utils").map
    local operators = require("config.operators")

    map("n", "<esc>", function()
        if mc.hasCursors() then
            mc.clearCursors()
            vim.api.nvim_exec_autocmds("ModeChanged", {})
        end

        if vim.snippet.active() then
            vim.snippet.stop()
        end
    end)

    -- turns multiple cursors into another vim command more than a full mode
    -- for linewise mode or when spanning multiple lines: create one cursor for each line, at the same position as the original one
    -- for charwise mode on a single line: create a single cursor at the destination of the motion
    operators.map_function("<M-c>", function(mode, region, extra, get)
        if mode == "line" or region[2][1] ~= region[1][1] then
            local original_column = vim.fn.virtcol(".")
            mc.action(function(ctx)
                for i = region[1][1] + 1, region[2][1] do
                    local cursor = ctx:addCursor()
                    cursor:setPos({ i, 1 })
                    cursor:feedkeys(original_column .. "|")
                end
            end)
        elseif mode == "char" then
            mc.action(function(ctx)
                local cursor = ctx:addCursor()
                cursor:setPos({ region[2][1], region[2][2] + 1 })
            end)
        end
        return nil
    end, { normal_only = true })

    map("x", "<M-c>", mc.visualToCursors)

    -- put one cursor at each current search result
    map("n", "<C-c>/", function()
        local search_pattern = vim.fn.getreg("/")
        local main_pos = vim.api.nvim_win_get_cursor(0)
        local matches = {}
        vim.api.nvim_win_set_cursor(0, { 1, 1 })

        local match = vim.fn.searchpos(search_pattern, "W")
        while match[1] ~= 0 do
            table.insert(matches, match)
            match = vim.fn.searchpos(search_pattern, "W")
        end

        vim.api.nvim_win_set_cursor(0, main_pos)
        mc.action(function(ctx)
            for _, pos in ipairs(matches) do
                local cursor = ctx:addCursor()
                cursor:setPos(pos)
            end
        end)
    end)

    -- align cursors: all to same column
    map({ "x", "n" }, "<C-c>a", function()
        mc.action(function(ctx)
            local maincol = ctx:mainCursor():getPos()[2]
            ctx:forEachCursor(function(cursor, i, all)
                cursor:feedkeys(maincol .. "|")
            end)
        end)
    end)

    local vinorm = {"n", "x"}

    map(vinorm, "<C-c>j", mc.nextCursor)
    map(vinorm, "<C-c>k", mc.prevCursor)
    map(vinorm, "<C-c>$", mc.lastCursor)
    map(vinorm, "<C-c>0", mc.firstCursor)

    map(vinorm, "<C-c>u", mc.restoreCursors)
    map(vinorm, "<C-c>t", mc.toggleCursor)
    map(vinorm, "<C-c>*", mc.matchAllAddCursors)

    map({ "x" }, "<C-c>s", mc.splitCursors)
    map({ "x" }, "<C-c>m", mc.matchCursors)
    map(vinorm, "<C-c>x", mc.deleteCursor)
    map(vinorm, "<C-c>A", mc.alignCursors)

    -- replace default I and A for visual mode
    map("x", "I", mc.insertVisual)
    map("x", "A", mc.appendVisual)
end

return M
