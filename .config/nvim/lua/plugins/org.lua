---@type LazySpec
local M = {}

M = {
    "nvim-orgmode/orgmode",
    cmd = { "Org" },
    ft = { "org" },
    keys = { "<space>A", "<space>w" },
    init = function()
        -- HACK: forward requests to the global Org object until it is loaded
        _G.Org = setmetatable({}, {
            __index = function(_, k)
                require("orgmode")
                return Org[k]
            end
        })
    end,
    dependencies = {
        "johk06/orgmode-eval",
        opts = {},
    }
}

---@type OrgConfigOpts
local opts = {
    hyperlinks = {
        sources = {
        }
    },
    ui = {
        folds = {
            colored = true
        },
    },
    org_agenda_files = {
        "~/org/**/*"
    },
    org_default_notes_file = "~/org/notes.org",
    org_todo_keywords = {
        "TODO(t)", "NEXT(n)", "WAITING(w)", "CURRENT(c)",
        "|",
        "DONE(d)", "NOPE(x)",
    },
    org_todo_keyword_faces = {
        -- HACK: see https://github.com/nvim-orgmode/orgmode/issues/983
        NEXT = ":foreground red",
        WAITING = ":foreground red",
        CURRENT = ":foreground red",
        NOPE = ":foreground red",
    },
    org_startup_folded = "inherit",
    org_hide_leading_stars = true,
    org_hide_emphasis_markers = true,
    org_startup_indented = true,
}

opts.org_capture_templates = {
    u = {
        description = "Unix Workflow",
        target = "~/org/unix/%^{Shell Utility}.org",
        template = "#+title: %?\n#+filetags: :unix: :cli: :programs:"

    },
    j = {
        description = "Journal",
        target = "~/org/journal/%<%Y-%m-%d>.org",
        template = {
            "#+title: Journal on %<%A, %d. %B>",
            "#+filetags: :journal:",
            "",
            "%?"
        }
    }
}

opts.mappings = {
    global = {
        org_agenda = "<space>A",
        org_capture = "<space>w", -- [w]rite about
    },
}

opts.mappings.agenda = {
    org_agenda_day_view           = "<localleader>d",
    org_agenda_month_view         = "<localleader>m",
    org_agenda_week_view          = "<localleader>w",
    org_agenda_year_view          = "<localleader>y",
    org_agenda_filter             = "<localleader>/",

    -- I like my find motions
    org_agenda_later              = "{",
    org_agenda_earlier            = "}",
    org_agenda_today              = ".",
    org_agenda_goto_date          = "?",

    org_agenda_add_note           = "<localleader>n",
    org_agenda_deadline           = "d",
    org_agenda_schedule           = "s",

    ---@diagnostic disable: assign-type-mismatch Type annotations do not match the docs
    org_agenda_archive            = false,
    org_agenda_set_effort         = false,
    org_agenda_clock_goto         = false,
    org_agenda_refile             = false,
    org_agenda_set_tags           = false,
    org_agenda_toggle_archive_tag = false,
    ---@diagnostic enable
}

opts.mappings.capture = {
    org_capture_kill = "<localleader>q",


    ---@diagnostic disable-next-line: assign-type-mismatch
    org_capture_refile = false,
}
opts.mappings.note = {
    org_note_kill = "<localleader>q",
}

opts.mappings.org = {
    org_toggle_heading                      = "<localleader>*",
    org_store_link                          = "<localleader>#",
    org_edit_special                        = "<localleader>e",
    org_add_note                            = "<localleader>n",
    org_archive_subtree                     = "<localleader>$",
    org_set_tags_command                    = "<localleader>t",
    org_toggle_archive_tag                  = "<localleader>a",
    org_meta_return                         = "<localleader>o",
    org_insert_heading_respect_content      = "<localleader>h",
    org_insert_todo_heading_respect_content = "<localleader>t",

    org_move_subtree_up                     = "<t",
    org_move_subtree_down                   = ">t",
    org_timestamp_down_day                  = "<d",
    org_timestamp_up_day                    = ">d",


    -- Use [y]ou like surround, e.g. [y]ou [s]urround
    org_deadline              = "yd",
    org_priority              = "yp",
    org_schedule              = "y@",
    org_time_stamp            = "y.",
    org_time_stamp_inactive   = "y!",
    org_toggle_timestamp_type = "g!",

    org_clock_in              = "<localleader>ci",
    org_clock_out             = "<localleader>cq",
    org_clock_cancel          = "<localleader>cc",
    org_clock_goto            = "<localleader>cg",

    org_export                = "<localleader>x",
    org_babel_tangle          = "<localleader>X",
    org_refile                = "<localleader>r",

    org_open_at_point         = "<cr>",

    ---@diagnostic disable: assign-type-mismatch
    org_insert_todo_heading   = false,
    org_set_effort            = false,
    org_insert_link           = false,
    org_cycle                 = false,
    ---@diagnostic enable
}

M.config = function()
    local utils = require("config.utils")
    local custom = require("config.plugins.orgmode")
    local eval = require("orgmode-eval")

    opts.ui.menu = { handler = custom.Menu }
    opts.org_custom_exports = {
        t = custom.typst_exporter
    }
    local orgmode = require("orgmode")
    orgmode.setup(opts)

    orgmode.links:add_type(custom.LineSearchLink)
    orgmode.links:add_type(custom.RegexSearchLink)

    utils.autogroup("config.orgmode", {
        FileType = {
            pattern = "org",
            callback = function(ev)
                local map = utils.local_mapper(ev.buf)
                map("n", "<localleader>l", "<cmd>Telescope orgmode insert_link<cr>")
                map("n", "<localleader>/", "<cmd>Telescope orgmode search_headings<cr>")
                map("i", "<C-l>", "<cmd>Telescope orgmode insert_link<cr>")

                -- The default <cr> mapping is nothing but broken
                map("i", "<cr>", "<cr>")

                map("i", "<M-CR>", function()
                    orgmode.action("org_mappings.meta_return")
                end)

                map("n", "<space>e", eval.run_code_block)
                map("n", "<space>E", eval.clear_buffer)

                -- Mimic markdown
                map("n", "gO", custom.table_of_contents)
            end
        }
    })
end

return M
