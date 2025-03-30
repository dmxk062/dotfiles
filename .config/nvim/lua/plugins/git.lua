---@type LazySpec
local M = {
    { "lewis6991/gitsigns.nvim" },
    { "tpope/vim-fugitive" },
}

--[[ Information {{{
Both fugitive and gitsigns are great git plugins
gitsigns generally performs better for basic features,
whereas fugitive imo provides more capabilities

I prefer gitsigns' buffer monitoring and interactive features,
but fugitive's commands and history capabilities are better

TODO: give other git plugins (i.e. lazygit) a serious try
}}} ]] --

local function map_on_git_buffer(buf)
    local gitsigns = require("gitsigns")
    local utils = require("config.utils")

    -- all git related mappings in normal mode use the "<space>g" prefix
    local map = utils.local_mapper(buf, { prefix = "<space>g" })

    local vimap = function(fn)
        return function()
            fn { vim.fn.line("."), vim.fn.line("v") }
        end
    end

    local function mapboth(keys, fn, desc)
        local tbl = { desc = desc }
        map("n", keys, fn, tbl)
        map("v", keys, vimap(fn), tbl)
    end

    map("n", "p", gitsigns.preview_hunk_inline, { desc = "Git: Preview hunk" })

    -- use fugitive cause its just better :(
    map("n", "d", "<cmd>rightbelow Gvdiffsplit<cr>", { desc = "Git: Diff with head" })
    map("n", "D", "<cmd>rightbelow Gvdiffsplit !<cr>", { desc = "Git: Diff with last commit" })
    map("n", "C", "<cmd>silent vertical G commit<cr>")

    map("n", "b", gitsigns.blame_line, { desc = "Git: Blame line" })
    map("n", "B", gitsigns.blame, { desc = "Git: Blame buffer" })

    map("n", "H", gitsigns.setqflist, { desc = "Git: Hunks to qflist" })
    map("n", "h", gitsigns.setloclist, { desc = "Git: Hunks to loclist" })
    map("n", "L", "<cmd>0Gclog<cr>", { desc = "Git: Log to qflist" })
    map("n", "l", "<cmd>0Gllog<cr>", { desc = "Git: Log to loclist" })

    map("n", "w", gitsigns.toggle_word_diff, { desc = "Git: Word diff" })

    mapboth("s", gitsigns.stage_hunk, "Git: Toggle stage")
    mapboth("U", gitsigns.reset_hunk, "Git: Reset")

    local ts_repeat = require("nvim-treesitter.textobjects.repeatable_move")
    local nh, ph = ts_repeat.make_repeatable_move_pair(
        function() gitsigns.nav_hunk("next") end,
        function() gitsigns.nav_hunk("prev") end
    )
    utils.map({ "n", "x", "o" }, "]g", nh, { buffer = buf })
    utils.map({ "n", "x", "o" }, "[g", ph, { buffer = buf })


    utils.map({ "x", "o" }, "ig", gitsigns.select_hunk, { buffer = buf })
end

-- gitsigns {{{
M[1].opts = {
    signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "^" },
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

    on_attach = map_on_git_buffer
}
-- }}}

-- fugitive {{{
M[2].config = function()
    vim.g.fugitive_dynamic_colors = false
    local utils = require("config.utils")

    utils.user_autogroup("config.fugitive", {
        FugitiveIndex = function(ev)
            -- enable folding and fold by default
            vim.wo[0][0].foldmethod = "syntax"
            vim.wo[0][0].foldlevel = 0

            -- show the relevant fold immediately
            -- this will be staged if there is one,
            -- otherwise it'll be unstaged
            vim.cmd.normal("Gzo[zzz")
        end,

        -- make G blame etc appear in the buffer list
        FugitivePager = function(ev)
            vim.bo[ev.buf].buflisted = true
        end,

        FugitiveCommit = function()
            vim.defer_fn(function()
                vim.wo[0][0].foldmethod = "syntax"
                vim.wo[0][0].foldlevel = 0
            end, 100)
        end,

        FugitiveObject = function()
            map_on_git_buffer(vim.api.nvim_get_current_buf())
        end
    })
end

-- }}}

return M
