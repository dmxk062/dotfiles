-- my own, *very* basic snippet completion for cmp

local M = {}

---@class Snippet
---@field name string
---@field body string[]|string|fun(): (string|string[])?
---@field do_hl boolean
---@field desc string?

--- ft = ...
--- _ : global snippets
---@type table<string, Snippet[]>
local snippets_for_ft = {
    _ = {},
    c = {
        {
            name = "main",
            desc = "Program entry point",
            body = {
                "int main(int argc, char* argv[]) {",
                "\t$1",
                "\treturn EXIT_SUCCESS;",
                "}"
            },
            do_hl = true
        }
    }
}

---@param dest lsp.CompletionItem[]
---@param snips Snippet[]
local function do_snippets(dest, snips)
    for _, s in ipairs(snips) do
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
            label = s.name,
            insertText = body,
            insertTextMode = 2,   -- adjust indentation
            kind = 15,            -- snippet
            insertTextFormat = 2, -- as snippet
            data = {
                prefix = s.name,
                body = body,
                highlight = s.do_hl,
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
