local M = {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
    },
    event = { "BufRead" },
}


local function fold_formatter(virtText, lnum, endLnum, width, truncate)
    local ret = {}
    local suffix = ("  %d lines..."):format(endLnum - lnum)
    local suff_width = vim.fn.strdisplaywidth(suffix)
    local target_width = width - suff_width
    local cur_width = 0
    for _, chunk in ipairs(virtText) do
        local chunktext = chunk[1]
        local hlgroup = chunk[2]
        local chunkWidth = vim.fn.strdisplaywidth(chunktext)
        if target_width > cur_width + chunkWidth then
            table.insert(ret, chunk)
        else
            chunktext = truncate(chunktext, target_width - cur_width)
            table.insert(ret, { chunktext, hlgroup })
            chunkWidth = vim.fn.strdisplaywidth(chunktext)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if cur_width + chunkWidth < target_width then
                suffix = suffix .. (" "):rep(target_width - cur_width - chunkWidth)
            end
            break
        end
        cur_width = cur_width + chunkWidth
    end
    table.insert(ret, { suffix, "Comment" })
    return ret
end

M.opts = {
    open_fold_hl_timeout = 0,
    fold_virt_text_handler = fold_formatter,
    close_fold_kinds_for_ft = {
        default = { "imports" },
    },
    provider_selector = function(bufnr, ft, bft)
        return { "lsp", "indent" }
    end,
    preview = {
        win_config = {
            border = "rounded",
            winblend = 0,
            list = false,
        },
        mappings = {
            scrollU = "<C-k>",
            scrollD = "<C-j>",
            jumpTop = "[",
            jumpBot = "]"
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

            --HACK: limit the width of the new limit to smth sane
            local parent_width = vim.api.nvim_win_get_width(0)
            local new_width
            if parent_width < 90 then
                new_width = parent_width - 10
            else
                new_width = 80
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
