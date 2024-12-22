-- {{{ test
-- }}}


local M = {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
    },
    event = { "BufRead" },
}

local function merged_provider(providers)
    return function(bufnr)
        local all = {}

        for _, provider in ipairs(providers) do
            local ok, folds = pcall(require("ufo").getFolds, bufnr, provider)
            vim.list_extend(all, folds or {})
        end

        return #all > 0 and all or nil
    end
end

local marker_start = function()
    return vim.split(vim.wo[0].foldmarker, ",")[1]
end

local commentstr = function()
    return vim.bo[0].commentstring:gsub("%%s", "")
end

local function fold_formatter(virt_text, row, end_row, width, truncate)
    local new_text = {}

    local first_line = virt_text[1][1]

    local potential_foldstart = first_line:gsub("^" .. commentstr(), "")
    local has_comment = #potential_foldstart ~= #first_line
    local _, _, title, marker, level = potential_foldstart:find("(.-)(" .. marker_start() .. ")(%d*)")

    local suffix = (" -> %d lines"):format(end_row - row)

    if marker and title then
        title = title:gsub("%s*$", "")
        if has_comment then
            table.insert(new_text, { string.format(vim.bo[0].commentstring, ""), "Comment" })
        end
        table.insert(new_text, { "# " .. title, "UfoFoldTitle" })
        if #level > 0 then
            table.insert(new_text, { " :" .. level, "Number" })
        end
    else
        local suff_width = vim.fn.strdisplaywidth(suffix)
        local target_width = width - suff_width
        local cur_width = 0
        for _, chunk in ipairs(virt_text) do
            local text = chunk[1]
            local text_width = vim.fn.strdisplaywidth(text)
            if target_width > cur_width + text_width then
                table.insert(new_text, chunk)
            else
                text = truncate(text, target_width - cur_width)
                table.insert(new_text, { text, chunk[2] })
                break
            end
            cur_width = cur_width + text_width
        end
    end
    table.insert(new_text, { suffix, "Comment" })
    return new_text
end

M.opts = {
    open_fold_hl_timeout = 0,
    fold_virt_text_handler = fold_formatter,
    close_fold_kinds_for_ft = {
        default = { "imports", "marker" },
    },
    provider_selector = function(bufnr, ft, bft)
        return { merged_provider({ "treesitter", "marker", "indent" }), function() return nil end }
    end,
    preview = {
        win_config = {
            border = "rounded",
            winblend = 0,
        },
        mappings = {
            jumpTop = "[",
            jumpBot = "]",
            switch = "K"
        }
    },
}

M.config = function(_, opts)
    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    local utils = require("utils")
    local ufo = require("ufo")
    ufo.setup(opts)

    utils.map("n", "zO", ufo.openAllFolds)
    utils.map("n", "zC", ufo.closeAllFolds)

    utils.map("n", "<S-k>", function()
        local winid = ufo.peekFoldedLinesUnderCursor()
        if not winid then
            vim.lsp.buf.hover()
        else
            --HACK: no better way rn
            vim.wo[winid].list = false
            vim.wo[winid].wrap = true

            --HACK: limit the width of the new window to smth sane
            local parent_width = vim.api.nvim_win_get_width(0)
            local new_width
            if parent_width < 90 then
                new_width = parent_width - 10
            else
                new_width = 90
            end
            vim.api.nvim_win_set_width(winid, new_width)
        end
    end)
    --HACK: reset colorscheme
    vim.schedule(function()
        vim.cmd.colorscheme(vim.g.colors_name)
    end)
end

return M
