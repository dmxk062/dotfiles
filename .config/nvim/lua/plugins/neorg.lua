local M = {
    "nvim-neorg/neorg",
    cmd          = { "Neorg" },
    ft           = { "norg" },
    dependencies = {
        "3rd/image.nvim"
    }
}

M.opts = {}
local function with_prefix(prefix, input)
    local tbl = {}
    for k, v in pairs(input) do
        tbl[prefix .. k] = v
    end
    return tbl
end

local hlprefix = "@neorg."
local headings = { 1, 2, 3, 4, 5, 6, 7, 8 }

local conceals = {
    code_block = {
        conceal = false,
        content_only = false,
        insert_enabled = false,
        highlight = hlprefix .. "code_block",
        padding = { left = 2 }
    },
    heading = {
        icons = vim.tbl_map(function(num) return  "▎" end, headings),
        highlights = vim.tbl_map(function(num) return hlprefix .. "h" .. num end, headings)
    },
    markup = {
        spoiler = {
            highlight = "Comment",
            icon = "*",
        }
    },
    ordered = {
        icons = {
            "1.",
            "1.",
            "A.",
            "a.",
            "I.",
            "i."
        }
    },
    todo = {
        undone    = { icon = " ", },
        cancelled = { icon = "󰩹", },
        done      = { icon = "󰄬", },
        pending   = { icon = "…", },
        urgent    = { icon = "!", },
        recurring = { icon = "󰑖", },
        uncertain = { icon = "?", },
        on_hold   = { icon = "󰒲", },
    },
    definition = {
        multi_prefix = {
            icon = "⟪"
        },
        multi_suffix = {
            icon = "⟫"
        },
        single = {
            icon = "≡"
        },
    },
    footnote = {
        multi_prefix = {
            icon = "⟪"
        },
        multi_suffix = {
            icon = "⟫"
        },
        single = {
            icon = "󰙎"
        },
    },
    quote = {
        icons = {
            "▎"
        }
    },
}

local highlights = {
    headings = vim.tbl_map(function(num)
        local hl = "+@markup.heading." .. num
        return { prefix = hl, title = hl }
    end, headings),
    quotes = vim.tbl_map(function(num)
        local hl = "+" .. hlprefix .. "quote." .. num
        return { prefix = hl, content = hl }
    end, headings),

    todo_items = {
        cancelled = "+" .. hlprefix .. "cancelled",
        undone = "+" .. hlprefix .. "undone",
        done = "+" .. hlprefix .. "done",
        pending = "+" .. hlprefix .. "pending",
        urgent = "+" .. hlprefix .. "urgent",
        recurring = "+" .. hlprefix .. "recurring",
        uncertain = "+" .. hlprefix .. "uncertain",
        on_hold = "+" .. hlprefix .. "on_hold",
    },
}

M.opts.load = with_prefix("core.", {
    highlights = {
        config = {
            highlights = highlights,
        }
    },
    dirman = {
        config = {
            workspaces = {
                thoughts = "~/Documents/thoughts/",
                journal = "~/Documents/journal",
                school = "~/Documents/school"
            }
        }
    },
    journal = {
        config = {
            workspace = "journal"
        }
    },
    completion = {
        config = {
            engine = "nvim-cmp"
        }
    },
    keybinds = {
        config = {
            default_keybinds = false
        }
    },
    concealer = {
        config = {
            icons = conceals
        }
    },
    ["todo-introspector"] = {
        config = {
            highlight_group = "Comment",
            format = function(completed, total)
                return string.format("=> %d out of %d (%0.f%%)", completed, total, (completed / total) * 100)
            end
        }
    },
    ["latex.renderer"] = {
        config = {
            render_on_enter = true,
        }
    },
    ["esupports.metagen"] = {
        config = {
            type = "auto",
            template = {
                { "title", },
                { "authors", function()
                    local usr = os.getenv("USER")
                    if usr == "dmx" or usr == "" then
                        return "jhk"
                    else
                        return usr
                    end
                end},
                { "categories", },
                { "created", },
                { "updated", },
            }
        }
    },
    promo = {},
    neorgcmd = {},
    ["qol.toc"] = {},
    ["qol.todo_items"] = {},
    ["looking-glass"] = {},
    ["integrations.treesitter"] = {},
    ["esupports.indent"] = {},
    ["text-objects"] = {},
    ["esupports.hop"] = {},
})

local normal_mappings = {
    [">>"] = "<Plug>(neorg.promo.promote.nested)",
    [">."] = "<Plug>(neorg.promo.promote)",
    ["<<"] = "<Plug>(neorg.promo.demote.nested)",
    ["<,"] = "<Plug>(neorg.promo.demote)",
    ["<CR>"] = "<Plug>(neorg.esupports.hop.hop-link)",
    ["<space>ce"] = "<Plug>(neorg.looking-glass.magnify-code-block)",
    ["<space>ta"] = "<Plug>(neorg.qol.todo-items.todo.task-ambiguous)",
    ["<space>td"] = "<Plug>(neorg.qol.todo-items.todo.task-done)",
    ["<space>tc"] = "<Plug>(neorg.qol.todo-items.todo.task-cancelled)",
    ["<space>th"] = "<Plug>(neorg.qol.todo-items.todo.task-on-hold)",
    ["<space>ti"] = "<Plug>(neorg.qol.todo-items.todo.task-important)",
    ["<space>t!"] = "<Plug>(neorg.qol.todo-items.todo.task-important)",
    ["<space>tp"] = "<Plug>(neorg.qol.todo-items.todo.task-pending)",
    ["<space>tr"] = "<Plug>(neorg.qol.todo-items.todo.task-recurring)",
    ["<space>tu"] = "<Plug>(neorg.qol.todo-items.todo.task-undone)",
    ["<space>t<space>"] = "<Plug>(neorg.qol.todo-items.todo.task-undone)",
}

M.config = function(_, opts)
    require("neorg").setup(opts)
    vim.api.nvim_create_autocmd("Filetype", {
        pattern = "norg",
        callback = function(args)
            local utils = require("utils")
            for key, action in pairs(normal_mappings) do
                utils.lmap(args.buf, "n", key, action)
            end
            vim.wo[0].conceallevel = 2
            utils.lmap(args.buf, "x", "<", "<Plug>(neorg.promo.demote.range)")
            utils.lmap(args.buf, "x", ">", "<Plug>(neorg.promo.promote.range)")
            utils.lmap(args.buf, {"x", "o"}, "ah", "<Plug>(neorg.text-objects.textobject.heading.outer)")
            utils.lmap(args.buf, {"x", "o"}, "ih", "<Plug>(neorg.text-objects.textobject.heading.inner)")
            utils.lmap(args.buf, {"x", "o"}, "at", "<Plug>(neorg.text-objects.textobject.tag.inner)")
            utils.lmap(args.buf, {"x", "o"}, "it", "<Plug>(neorg.text-objects.textobject.tag.inner)")
        end
    })
end

return M
