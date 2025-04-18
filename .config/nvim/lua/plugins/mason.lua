local mason_PATH = vim.fn.stdpath("data") .. "/mason/bin"
local PACKAGES = {
    ["asm-lsp"]                     = "asm-lsp",
    ["bash-language-server"]        = "bash-language-server",
    ["clangd"]                      = "clangd",
    ["jedi-language-server"]        = "jedi-language-server",
    ["lua-language-server"]         = "lua-language-server",
    ["marksman"]                    = "marksman",
    ["typos-lsp"]                   = "typos-lsp",
    ["vscode-json-language-server"] = "json-lsp",
    ["yaml-language-server"]        = "yaml-language-server",
    ["typst-lsp"]                   = "typst-lsp",
}

---@param pkg Package
local install_package = function(pkg, is_update)
    vim.notify(("Mason: %s '%s'"):format(is_update and "updating" or "installing", pkg.name))
    pkg:once("install:success", vim.schedule_wrap(function()
        vim.notify(("Mason: %s '%s'"):format(is_update and "updated" or "installed", pkg.name))
    end))
    pkg:once("install:failed", vim.schedule_wrap(function()
        vim.notify(("Mason: failed to %s '%s'"):format(is_update and "update" or "install", pkg.name),
            vim.log.levels.ERROR)
    end))

    pkg:install()
end

local ensure_packages_installed = function()
    local registry = require("mason-registry")
    for program, package in pairs(PACKAGES) do
        local path = vim.fn.exepath(program)
        -- package is installed via the system, do not touch it
        if path ~= "" and not vim.startswith(path, mason_PATH) then
            goto continue
        end

        local pack = registry.get_package(package)
        if pack:is_installed() then
            pack:check_new_version(function(has_new_ver, ver)
                if not has_new_ver then
                    return
                end
                install_package(pack, true)
            end)
        else
            install_package(pack)
        end

        ::continue::
    end
end


local opts = {
    ui = {
        width = 0.8,
        height = 0.8,
        border = "rounded",
        icons = {
            package_installed   = "i",
            package_pending     = "…",
            package_uninstalled = "~",
        }
    }
}

---@type LazySpec
local M = {
    "williamboman/mason.nvim",
    event = { "VeryLazy" },
    init = function()
        -- make packages available before Mason is actually loaded
        vim.env.PATH = mason_PATH .. ":" .. vim.env.PATH
    end,
    config = function()
        require("mason").setup(opts)
        vim.defer_fn(ensure_packages_installed, 300)
    end
}

return M
