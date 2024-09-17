local M = {
    "nvim-neorg/neorg",
    cmd = { "Neorg" },
    ft  = { "norg" }
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
        icons = vim.tbl_map(function(num) return num .. "." end, headings),
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
    }
}

local highlights = {
    headings = vim.tbl_map(function(num)
        local hl = "+@markup.heading." .. num
        return { prefix = hl, title = hl }
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
    }
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
                journal = "~/Documents/journal"
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
    neorgcmd = {},
    concealer = {
        config = {
            icons = conceals
        }
    },
    promo = {},
    ["qol.toc"] = {},
    ["qol.todo_items"] = {},
    ["todo-introspector"] = {
        config = {
            highlight_group = "Comment"
        }
    },
    ["looking-glass"] = {},
    -- autocommands = {},
    ["integrations.treesitter"] = {},
    ["esupports.indent"] = {},
    ["esupports.hop"] = {},
})

local normal_mappings = {
    [">>"] = "<Plug>(neorg.promo.promote.nested)",
    [">."] = "<Plug>(neorg.promo.promote)",
    ["<<"] = "<Plug>(neorg.promo.demote.nested)",
    ["<,"] = "<Plug>(neorg.promo.demote)",
}

M.config = function(_, opts)
    require("neorg").setup(opts)
    vim.api.nvim_create_autocmd("Filetype", {
        pattern = "norg",
        callback = function(args)
            local function map(mode, keys, cb)
                require("utils").lmap(args.buf, mode, keys, cb)
            end
            for key, action in pairs(normal_mappings) do
                map("n", key, action)
            end
            vim.wo[0].conceallevel = 2
            -- vim.wo[0].concealcursor = "nc"
        end
    })
end

return M
