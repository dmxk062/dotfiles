---@type LazySpec
local M = {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
}

--[[ Information {{{
Multiple cursors for neovim:
I generally use them as a replacement for macros and complex :g commands

Leader Key: -

Ways to add cursors:
- motion: --<motion>
- search: /<search term><cr>-/
- word match (like *):
    - all: -*
    - in scope: -w<motion>
    - custom match in scope: -o<motion><motion>
- splitting / matching a visual selection:
    - split: -s<regex><cr>
    - match: -m<regex><cr>

Actions to perform on cursors:
- Perform *completely normal* vim edits
- Each cursor has its own undo, registers &c
- Align the text after/on cursors: -A
}}} --]]

function M.config()
    local mc = require("multicursor-nvim")
    mc.setup()

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
    operators.map_function("--", function(mode, region, extra, get, set)
        if mode == "line" or region[2][1] ~= region[1][1] then
            local original_column = vim.fn.charcol(".")
            mc.action(function(ctx)
                for i = region[1][1] + 1, region[2][1] do
                    local cursor = ctx:addCursor()
                    cursor:setPos({ i, original_column })
                    cursor:feedkeys(original_column .. "|")
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
    map("n", "-/", mc.searchAllAddCursors, { desc = "Cursor: New for /" })

    require("config.lsp").lsp_map("n", "-s", function()
        local fname = vim.api.nvim_buf_get_name(0)
        local first = true
        mc.action(function(ctx)
            vim.lsp.buf.references(nil, {
                on_list = function(res)
                    for _, item in ipairs(res.items) do
                        if item.filename == fname then
                            if not first then
                                local cursor = ctx:addCursor()
                                cursor:setPos { item.lnum, item.col }
                            else
                                vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
                                first = false
                            end
                        end
                    end
                end
            })
        end)
    end, { desc = "Cursor: New for symbol" })

    -- align cursors: all to same column
    map({ "n", "x" }, "-a", function()
        mc.action(function(ctx)
            local maincol = vim.fn.charcol(".")
            ctx:forEachCursor(function(cursor)
                if not cursor:isMainCursor() then
                    cursor:feedkeys(maincol .. "|")
                end
            end)
        end)
    end, { desc = "Cursor: Align column" })

    local vinorm = { "n", "x" }

    map(vinorm, "-x", mc.deleteCursor, { desc = "Cursor: Delete current" })
    map(vinorm, "-j", mc.nextCursor, { desc = "Cursor: Next below" })
    map(vinorm, "-k", mc.prevCursor, { desc = "Cursor: Next above" })
    map(vinorm, "-$", mc.lastCursor, { desc = "Cursor: Last" })
    map(vinorm, "-0", mc.firstCursor, { desc = "Cursor: First" })

    map(vinorm, "-n", function() mc.matchAddCursor(1) end, { desc = "Cursor: New on next *" })
    map(vinorm, "-p", function() mc.matchAddCursor(-1) end, { desc = "Cursor: New on prev *" })
    map(vinorm, "-*", mc.matchAllAddCursors, { desc = "Cursor: New on all *" })

    -- really useful with syntactically aware textobjects:
    -- -wif puts a cursor on every match in a function
    -- -wi<space> in lua does the same for a block
    map(vinorm, "-w", function()
        ---@diagnostic disable-next-line: missing-fields
        mc.operator { motion = "iw" }
    end, { desc = "Cursor: New for word in" })

    -- allows for things that are more than one <word>, e.g. i.
    map(vinorm, "-o", mc.operator, { desc = "Cursor: New for obj in" })

    map(vinorm, "-u", mc.restoreCursors, { desc = "Cursor: Undo clear" })

    -- visual selections
    map({ "x" }, "-s", mc.splitCursors, { desc = "Cursor: Split visual" })
    map({ "x" }, "-m", mc.matchCursors, { desc = "Cursor: Match visual" })
    map(vinorm, "-A", mc.alignCursors, { desc = "Cursor: Align content" })

    -- replace default I and A for visual mode
    map("x", "I", mc.insertVisual)
    map("x", "A", mc.appendVisual)


    mc.addKeymapLayer(function(set)
        set("n", "-i", function()
            mc.action(function(ctx)
                ctx:forEachCursor(function(cursor, i, t)
                    cursor:feedkeys(("i%d\x1b"):format(i), {
                        remap = false
                    })
                end)
            end)
        end, { desc = "Cursor: Insert index" })
    end)
end

return M
