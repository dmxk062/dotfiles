local M = {
    "saghen/blink.cmp",
    build = "cargo build --release",
    dependencies = {
    }
}

M.opts = {}

M.opts.keymap = {
    preset = "none",

    ["<C-p>"] = { "show", "select_prev", "fallback" },
    ["<C-n>"] = { "show", "select_next", "fallback" },
    ["<C-e>"] = { "cancel", "fallback" },
    ["<cr>"] = { "accept", "fallback" },
}

M.opts.signature = {
    enabled = true,
    trigger = {
        enabled = true
    }
}

M.opts.cmdline = {
    completion = {
        menu = {
            -- incredibly useful for :find
            auto_show = true
        }
    }
}

M.opts.completion = {
    list = {
        max_items = 96,
    },
    documentation = {
        auto_show = true,
        auto_show_delay_ms = 50,
        window = {
            scrollbar = false,
        }
    },
    menu = {
        scrollbar = false,
        draw = {
            columns = {
                { "label",    "label_description", gap = 1 },
                { "kind_icon" },
            },
            components = {}
        }
    }
}

M.opts.completion.menu.draw.components = {
    kind_icon = {
        text = function(ctx)
            local utils = require("config.utils")
            if ctx.source_name == "Cmdline" then
                return
            end

            return utils.lsp_symbols[ctx.kind]
        end,
    },
    label = {
        width = { fill = true, max = 40 },
    }
}

M.opts.sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
        oil = { "path", "buffer", "snippets" },
    },
    providers = {
        path = {
            opts = {
                -- more useful tbh
                get_cwd = function()
                    return vim.fn.getcwd()
                end
            }
        }
    }
}


return M
