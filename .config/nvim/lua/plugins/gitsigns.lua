local M = {
    "lewis6991/gitsigns.nvim",
}

M.opts = {
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
}

M.config = function(_, opts)
    local gitsigns = require("gitsigns")
    opts.on_attach = function(bufnr)
        local map = require("utils").local_mapper(bufnr)
        local prefix = "<space>g"

        map("n", prefix .. "t", gitsigns.toggle_signs)
        map("n", prefix .. "p", gitsigns.preview_hunk)
        -- use fugitive cause its just better :(
        map("n", prefix .. "d", "<cmd>Gvdiffsplit<cr>")
        map("n", prefix .. "D", "<cmd>Gvdiffsplit !^<cr>")
        map("n", prefix .. "b", gitsigns.blame_line)
        map("n", prefix .. "B", gitsigns.blame)
        map("n", prefix .. "c", gitsigns.setqflist)

        map("n", prefix .. "s", gitsigns.stage_hunk)
        map("n", prefix .. "u", gitsigns.undo_stage_hunk)
        map("n", prefix .. "R", gitsigns.reset_hunk)

        map("n", prefix .. "w", gitsigns.toggle_word_diff)
        map("n", prefix .. "r", gitsigns.toggle_deleted)

        map({ "x", "o" }, "ig", gitsigns.select_hunk)
    end

    gitsigns.setup(opts)
end

return M
