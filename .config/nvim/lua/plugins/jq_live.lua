return {
    dir = vim.fn.stdpath("config") .. "/lua/modules/jq_live",
    ft = {"json", "jsonc"},
    cmd = {"Jq", "JqQuery"},
    opts = {
        live_query = {
            callback = function(buf, input, output)
                require("cmp").setup.buffer {
                    sources = {
                        name = "buffer", option = {
                            get_bufnrs = function()
                                return {input, buf}
                            end
                        }
                    }
                }
            end
        }
    },
}
