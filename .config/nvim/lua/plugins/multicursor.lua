---@type LazySpec
local M = {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
}

M.opts = {}

--[[ Information {{{
Multiple cursors for neovim:
I generally use them as a replacement for macros and complex :g commands

Ways to add cursors:
- motion: <M-c><motion>
- search: /<search term><cr><C-c>/
- word match (like *):
    - next: <C-n>
    - prev: <C-p>
    - all: <C-c>*
    - in scope: <C-c>w<motion>
    - custom match in scope: <C-c>o<motion><motion>
- splitting / matching a visual selection:
    - split: <C-c>s<regex><cr>
    - match: <C-c>m<regex><cr>

Actions to perform on cursors:
- Perform *completely normal* vim edits
- Each cursor has its own undo, registers &c
- Align the text after/on cursors: <C-c>A
}}} --]]

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
    operators.map_function("<M-c>", function(mode, region, extra, get, set)
        if mode == "line" or region[2][1] ~= region[1][1] then
            local original_column = vim.fn.virtcol(".")
            mc.action(function(ctx)
                for i = region[1][1] + 1, region[2][1] do
                    local feedkeys = ctx:addCursor()
                    feedkeys:setPos({ i, 1 })
                    feedkeys:feedkeys(original_column .. "|")
                end
            end)
        elseif mode == "char" then
            mc.action(function(ctx)
                local cursor = ctx:addCursor()
                cursor:setPos({ region[2][1], region[2][2] + 1 })
            end)
        end
    end, { normal_only = true, no_repeated = true, desc = "Cursor: New for motion" })

    map("x", "<M-c>", mc.visualToCursors, { desc = "Cursor: On each line" })

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
    end, { desc = "Cursor: New for /" })

    -- align cursors: all to same column
    map({ "n", "x" }, "<C-c>a", function()
        mc.action(function(ctx)
            local maincol = ctx:mainCursor():getPos()[2]
            ctx:forEachCursor(function(cursor, i, all)
                cursor:feedkeys(maincol .. "|")
            end)
        end)
    end, { desc = "Cursor: Align column" })

    local vinorm = { "n", "x" }

    map(vinorm, "<C-c>x", mc.deleteCursor, { desc = "Cursor: Delete current" })
    map(vinorm, "<C-c>j", mc.nextCursor, { desc = "Cursor: Next below" })
    map(vinorm, "<C-c>k", mc.prevCursor, { desc = "Cursor: Next above" })
    map(vinorm, "<C-c>$", mc.lastCursor, { desc = "Cursor: Last" })
    map(vinorm, "<C-c>0", mc.firstCursor, { desc = "Cursor: First" })

    map(vinorm, "<C-c>n", function() mc.matchAddCursor(1) end, { desc = "Cursor: New on next *" })
    map(vinorm, "<C-c>p", function() mc.matchAddCursor(-1) end, { desc = "Cursor: New on prev *" })
    map(vinorm, "<C-c>*", mc.matchAllAddCursors, { desc = "Cursor: New on all *" })

    -- really useful with syntactically aware textobjects:
    -- <C-c>wif puts a cursor on every match in a function
    -- <C-c>wi<space> in lua does the same for a block
    map(vinorm, "<C-c>w", function()
        mc.operator { motion = "iw" }
    end, { desc = "Cursor: New for word in" })

    -- allows for things that are more than one <word>, e.g. i.
    map(vinorm, "<C-c>o", mc.operator, { desc = "Cursor: New for obj in" })

    map(vinorm, "<C-c>u", mc.restoreCursors, { desc = "Cursor: Undo clear" })

    -- visual selections
    map({ "x" }, "<C-c>s", mc.splitCursors, { desc = "Cursor: Split visual" })
    map({ "x" }, "<C-c>m", mc.matchCursors, { desc = "Cursor: Match visual" })
    map(vinorm, "<C-c>A", mc.alignCursors, { desc = "Cursor: Align content" })

    -- replace default I and A for visual mode
    map("x", "I", mc.insertVisual)
    map("x", "A", mc.appendVisual)
end

return M
