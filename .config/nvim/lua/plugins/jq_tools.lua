return {
    "dmxk062/jq_tools.nvim",
    ft = { "json", "jsonc" },
    cmd = { "Jq", "JqQuery" },
    opts = {
        live_query = {
            callback = function(buf, input, output)
                local cmp = require("cmp")
                vim.schedule(function()
                    local oldbuf = vim.api.nvim_get_current_buf()
                    vim.api.nvim_set_current_buf(input)
                    cmp.setup.buffer({
                        sources = {
                            { name = "luasnip" },
                            { name = "buffer", option = { get_bufnrs = function() return { input, buf } end } }
                        }
                    })
                    vim.api.nvim_set_current_buf(oldbuf)
                end)
            end
        }

    }
}
