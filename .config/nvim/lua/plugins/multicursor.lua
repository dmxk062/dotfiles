local M = {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
}

M.opts = {}

function M.config(_, opts)
    local mc = require("multicursor-nvim")
    mc.setup(opts)

    local map = require("utils").map
    local operators = require("operators")

    map("n", "<esc>", function()
        if mc.hasCursors() then
            mc.clearCursors()
        end

        if vim.snippet.active() then
            vim.snippet.stop()
        end
    end)

    -- replace default I and A for visual mode
    map("x", "I", mc.insertVisual)
    map("x", "A", mc.appendVisual)

    -- turns multiple cursors into another vim command more than a full mode
    -- for linewise mode or when spanning multiple lines: create one cursor for each line, at the same position as the original one
    -- for charwise mode on a single line: create a single cursor at the destination of the motion
    operators.map_function("<space>c", function(mode, region, extra, get)
        if mode == "line" or region[2][1] ~= region[1][1] then
            mc.action(function(ctx)
                -- selection may start before actual cursor pos in case of textobject
                local start_pos = region[1][2] + 1
                for i = region[1][1] + 1, region[2][1] do
                    local cursor = ctx:addCursor()
                    cursor:setPos({ i, 0 })
                    cursor:feedkeys(start_pos .. "|")
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

    map("x", "<space>c", mc.visualToCursors)

    -- put one cursor at each current search result
    map("n", "<space>C/", function()
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
    map({ "x", "n" }, "<space>Ca", function()
        mc.action(function(ctx)
            local maincol = ctx:mainCursor():getPos()[2]
            ctx:forEachCursor(function(cursor, i, all)
                cursor:feedkeys(maincol .. "|")
            end)
        end)
    end)

    map({ "x" }, "<space>Cs", mc.splitCursors)
    map({ "x" }, "<space>Cm", mc.matchCursors)
end

return M
