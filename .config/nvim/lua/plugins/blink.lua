---@type LazySpec
local M = {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    build = "cargo build --release",
    dependencies = {},
}

---@type blink.cmp.Config
M.opts = {}

M.opts.keymap = {
    preset    = "none",
    ["<C-p>"] = { "show", "select_prev", "fallback" },
    ["<C-n>"] = { "show", "select_next", "fallback" },
    ["<C-e>"] = { "cancel", "fallback" },
    ["<cr>"]  = { "accept", "fallback" },
    ["<C-y>"] = { "accept", "fallback" },
}

-- quick accept with <C-number>
for i = 1, 9 do
    M.opts.keymap[("<C-%d>"):format(i)] = { function(cmp)
        cmp.accept { index = i }
    end }
end

M.opts.signature = {
    enabled = true,
    trigger = {
        enabled = true
    }
}

M.opts.cmdline = {
    keymap = {
        -- mapping <left> and <right> is not what I ever want
        preset     = "none",

        ["<Tab>"]  = { "show_and_insert", "select_next" },
        ["<C-n>"]  = { "select_next", "fallback" },
        ["<C-p>"]  = { "select_prev", "fallback" },
        ["<C-e>"]  = { "cancel" },
        ["<C-y>"]  = { "select_and_accept" },
        ["<S-CR>"] = { "select_accept_and_enter" },
    },
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
        max_height = 24,
        draw = {
            columns = {
                { "index" },
                { "label",    "label_description", gap = 1 },
                { "kind_icon" },
            },
            components = {}
        }
    },
}

M.opts.completion.menu.draw.components = {
    index = {
        text = function(ctx)
            return ctx.idx > 9 and "" or tostring(ctx.idx)
        end,
        highlight = "BlinkCmpIndex",
    },
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
    },
    label_description = {
        width = { max = 20 }
    }
}

M.opts.sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
        oil = { "path", "buffer", "snippets" },
        Input = { "omni" },
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
