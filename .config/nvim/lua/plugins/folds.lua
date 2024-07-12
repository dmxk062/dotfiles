return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
        "luukvbaal/statuscol.nvim",
    },
    config = function()
        local utils = require("utils")
        local ufo = require("ufo")
        vim.o.foldcolumn = "1"
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        utils.map("n", "zO", ufo.openAllFolds)
        utils.map("n", "zC", ufo.closeAllFolds)

        local handler = function(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local suffix = ("  %d lines..."):format(endLnum - lnum)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0
            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local hlGroup = "Comment"
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    table.insert(newVirtText, { chunkText, hlGroup })
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    -- str width returned from truncate() may less than 2nd argument, need padding
                    if curWidth + chunkWidth < targetWidth then
                        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                    end
                    break
                end
                curWidth = curWidth + chunkWidth
            end
            table.insert(newVirtText, { suffix, "Comment" })
            return newVirtText
        end
        ufo.setup {
            open_fold_hl_timeout = 0,
            fold_virt_text_handler = handler,
            close_fold_kinds_for_ft = {
                default = {"imports"},
            },
            preview = {
                win_config = {
                    border = "rounded",
                    winblend = 0
                },
                mappings = {
                    scrollU = "<C-k>",
                    scrollD = "<C-j>",
                    jumpTop = "[",
                    jumpBot = "]"
                }
            },
        }
        utils.map("n", "<S-k>", function()
            local winid = ufo.peekFoldedLinesUnderCursor()
            if not winid then
                vim.lsp.buf.hover()
            end
        end)
        local builtin = require("statuscol.builtin")
        require("statuscol").setup {
            segments = {
                { text = { "%s" },                  click = "v:lua.ScSa" },
                { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
                {
                    text = { builtin.lnumfunc, " " },
                    condition = { true, builtin.not_empty },
                    click = "v:lua.ScLa",
                }
            },
        } 
    end
}
