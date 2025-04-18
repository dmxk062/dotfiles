---@type LazySpec
local M = {
    "chomosuke/typst-preview.nvim",
    ft = { "typst" },
    opts = {
        open_cmd = "firefox %s >/dev/null 2>&1",
        dependencies_bin = {
            tinymist = "tinymist", -- use system or mason version
        }

    }
}

M.init = function()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function()
            vim.cmd.TypstPreview()
        end
    })
end

return M
