local M = {
    { "lewis6991/gitsigns.nvim" },
    { "tpope/vim-fugitive" },
}

--[[ Rationale {{{
Both fugitive and gitsigns are great git plugins
gitsigns generally performs better for basic features,
whereas fugitive imo provides more capabilities

I prefer gitsigns' buffer monitoring and interactive features,
but fugitive's commands and history capabilities are better
}}} ]]--

-- gitsigns {{{
M[1].opts = {
    signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "-" },
        changedelete = { text = "~" },
        untracked    = { text = "." },
    },

    preview_config = {
        border = "rounded",
    },

    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "right_align",
        delay = 200,
    },

    current_line_blame_formatter = "<author>, <author_time:%Y/%m/%d> - <summary>",

    diff_opts = {
        vertical = true,
    },

    on_attach = function(buf)
        local gitsigns = require("gitsigns")
        local utils = require("config.utils")
        -- all git related mappings in normal mode use the "<space>g" prefix
        local map = utils.local_mapper(buf, "<space>g")

        map("n", "p", gitsigns.preview_hunk)

        -- use fugitive cause its just better :(
        map("n", "d", "<cmd>rightbelow Gvdiffsplit<cr>")
        map("n", "D", "<cmd>rightbelow Gvdiffsplit !<cr>")
        map("n", "v", "<cmd>rightbelow Gdiffsplit<cr>")
        map("n", "V", "<cmd>rightbelow Gdiffsplit<cr>")

        map("n", "b", gitsigns.blame_line)
        map("n", "B", gitsigns.blame)

        map("n", "q", gitsigns.setqflist)
        map("n", "l", gitsigns.setloclist)
        map("n", "L", "<cmd>0Gllog<cr>")
        map("n", "Q", "<cmd>0Gclog<cr>")

        map("n", "s", gitsigns.stage_hunk)
        map("n", "u", gitsigns.undo_stage_hunk)
        map("n", "U", gitsigns.reset_hunk)

        map("n", "w", gitsigns.toggle_word_diff)
        map("n", "r", gitsigns.toggle_deleted)


        utils.map({ "x", "o" }, "ig", gitsigns.select_hunk, { buffer = buf })
    end
}
-- }}}

-- fugitive {{{
M[2].config = function ()
    vim.g.fugitive_dynamic_colors = false

    vim.api.nvim_create_autocmd({"User"}, {
        pattern = "FugitiveIndex",
        callback = function(ev)
            -- enable folding and fold by default
            vim.wo[0][0].foldmethod = "syntax"
            vim.wo[0][0].foldlevel = 0
        end
    })
end

-- }}}

return M
