-- my own, *very* basic snippet completion for cmp

local M = {}

---@class Snippet
---@field body string[]|string|fun(): (string|string[])?
---@field no_hl boolean?
---@field desc string?

---@alias Snippets table<string, Snippet>

--- ft = ...
--- _ : global snippets
---@type table<string, Snippets>
local snippets_for_ft = {
    _ = {
        EPOCH = {
            desc = "Current UNIX time stamp",
            body = function () return vim.fn.strftime("%s") end,
            no_hl = true,
        }
    },
    c = {
        main = {
            desc = "Program entry point",
            body = {
                "int main(int argc, char* argv[]) {",
                "\t$1",
                "\treturn EXIT_SUCCESS;",
                "}"
            },
        }
    },
    markdown = {
        superscript = {
            body = "<sup>$1</sup>",
        },
        subscript = {
            body = "<supb$1</sub>",
        }
    }
}

---@param dest lsp.CompletionItem[]
---@param snips Snippets
local function do_snippets(dest, snips)
    for name, s in pairs(snips) do
        local body = s.body
        if type(body) == "function" then
            body = body()
            if not body then
                goto continue
            end
        end

        if type(body) == "table" then
            body = table.concat(body, "\n")
        end

        ---@type lsp.CompletionItem
        local r = {
            label = name,
            insertText = body,
            insertTextMode = 2,   -- adjust indentation
            kind = 15,            -- snippet
            insertTextFormat = 2, -- as snippet
            data = {
                prefix = name,
                body = body,
                highlight = not s.no_hl,
                description = s.desc,
            }
        }
        table.insert(dest, r)

        ::continue::
    end
end

local Cmp_source = {
    is_available = function() return true end,

    ---@param cb function
    complete = function(_, _, cb)
        local ft = vim.bo[0].ft

        local snips = snippets_for_ft[ft]

        ---@type lsp.CompletionItem[]
        local res = {}

        if snips then
            do_snippets(res, snips)
        end

        local gsnips = snippets_for_ft._
        if gsnips then
            do_snippets(res, gsnips)
        end

        cb(res)
    end,

    ---@param ci lsp.CompletionItem
    ---@param cb function
    resolve = function(_, ci, cb)
        local data = ci.data or {}
        local pv = data.body


        if data.highlight then
            pv = string.format("```%s\n%s\n```", vim.bo.filetype, pv)
        end
        if data.description then
            pv = data.description .. "\n" .. pv
        end


        ci.documentation = {
            kind = "markdown",
            value = pv,
        }

        cb(ci)
    end,

    ---@param ci lsp.CompletionItem
    ---@param cb function
    execute = function(_, ci, cb)
        cb(ci)
    end
}

function M.setup()
    require("cmp").register_source("snippet", Cmp_source)
end

return M
