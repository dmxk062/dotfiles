--[[ Replacement for spellfile.vim {{{
Partially replicate what spellfile.vim does, just in a more modern way

Why? spellfile.vim relies on netrw, is written in vimscript and is not that readable
}}} ]]

-- use the same mirror spellfile.vim uses
local spell_file_url = "https://ftp.nluug.nl/pub/vim/runtime/spell/"

local spellfile_donwload_dir = vim.tbl_map(function(dir)
    local spelldir = dir .. "/spell"
    if vim.uv.fs_access(spelldir, "W") and vim.uv.fs_stat(spelldir).type == "directory" then
        return spelldir .. "/"
    end
end, vim.opt.runtimepath:get())[1]


local M = {}
local fn = vim.fn
local api = vim.api

local download_spellfile = function(lang)
    -- TODO: handle other encodings
    -- but tbh, utf-8 is the only real modern encoding
    local name = lang .. ".utf-8"

    local spl = name .. ".spl"
    local sug = name .. ".sug"
    local splpath = spellfile_donwload_dir .. spl
    local sugpath = spellfile_donwload_dir .. sug

    vim.system({
        "curl", "--fail", "--no-progress-meter", "--parallel",
        spell_file_url .. spl, "--output", splpath,
        spell_file_url .. sug, "--output", sugpath,
    }, {}, function(res)
        if res.code ~= 0 then
            vim.uv.fs_unlink(splpath)
            vim.uv.fs_unlink(sugpath)

            vim.schedule(function()
                vim.notify("Spell: failed to spellfiles for " .. lang, vim.log.levels.ERROR)
            end)
        else
            print("Spell: fetched " .. lang)
        end
    end)
end

M.popup = function()
    local word = fn.expand("<cWORD>")
    local suggestions = fn.spellsuggest(word, 32)
    vim.ui.select(suggestions, { prompt = "Spell" }, function(replacement)
        if not replacement then
            return
        end

        vim.cmd('normal! "_ciW' .. replacement)
        vim.cmd.stopinsert()
    end)
end

M.spell_cmd = function(arguments)
    local args = arguments.fargs
    if args[1] == "get" then
        for i = 2, #args do
            download_spellfile(args[i])
        end
    elseif args[1] == "set" then
        vim.bo.spelllang = args[2] or "en_us"
        vim.wo.spell = true
    elseif args[1] == "toggle" then
        vim.wo.spell = not vim.wo.spell
    elseif args[1] == "off" then
        vim.wo.spell = false
    end
end

M.tried_languages = {}

local try_to_download = function(name)
    if M.tried_languages[name] then
        print("Already tried to get language: " .. name)
        return
    end
    print("Language not found: " .. name .. ", trying to download...")
    M.tried_languages[name] = true
    download_spellfile(name)
end

api.nvim_create_autocmd("SpellFileMissing", {
    callback = function(ev)
        try_to_download(ev.match)
    end
})

-- Completion constants {{{
local spell_toplevel = {
    "set",
    "get",
    "off",
    "toggle"
}

-- non authoritative list
-- taken from the mirror
local spell_languages = {
    "af",
    "am",
    "bg",
    "br",
    "ca",
    "cs",
    "cy",
    "da",
    "de",
    "el",
    "en",
    "eo",
    "es",
    "eu",
    "fo",
    "fr",
    "ga",
    "gd",
    "gl",
    "he",
    "hr",
    "hu",
    "id",
    "it",
    "ku",
    "la",
    "lt",
    "lv",
    "mg",
    "mi",
    "ms",
    "nb",
    "nl",
    "nn",
    "ny",
    "pl",
    "pt",
    "ro",
    "ru",
    "rw",
    "sk",
    "sl",
    "sr",
    "sv",
    "sw",
    "tet",
    "th",
    "tl",
    "tn",
    "tr",
    "uk",
    "yi",
    "yi-tr",
    "zu"
}
-- }}}

M.spell_cmd_complete = function(lead, line, cpos)
    local arg = vim.trim(line:match("^Spell%s*(.*)"))

    if arg == "" then
        return spell_toplevel
    elseif arg == "off" or arg == "toggle" then
        return
    elseif arg == "set" or vim.startswith(arg, "get") then
        return spell_languages
    end
end

return M
