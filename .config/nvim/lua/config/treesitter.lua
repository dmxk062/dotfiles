--[[
Custom predicates and directives for Treesitter

Mostly to avoid expensive operations within treesitter-scheme itself or as an
escape hatch to do things treesitter wasn't made to do (e.g. selecting characters).

All predicates and directives should have a jhk- prefix
to avoid collisions with those added by e.g. nvim-treesitter.
]]


-- Conceal Symbol Names in Typst {{{
local typst_symbol_names = {
    -- greek alphabet
    Alpha    = "Α",
    alpha    = "α",
    Beta     = "Β",
    beta     = "β",
    Gamma    = "Γ",
    gamma    = "γ",
    Delta    = "Δ",
    delta    = "δ",
    Epsilon  = "Ε",
    epsilon  = "ε",
    Zeta     = "Ζ",
    zeta     = "ζ",
    Eta      = "Η",
    eta      = "η",
    Theta    = "Θ",
    theta    = "θ",
    Iota     = "Ι",
    iota     = "ι",
    Kappa    = "Κ",
    kappa    = "κ",
    Lambda   = "Λ",
    lambda   = "λ",
    Mu       = "Μ",
    mu       = "μ",
    Nu       = "Ν",
    nu       = "ν",
    Xi       = "ξ",
    xi       = "ξ",
    Omicron  = "Ο",
    omicron  = "ο",
    Pi       = "Π",
    pi       = "π",
    Rho      = "Ρ",
    rho      = "ρ",
    Sigma    = "Σ",
    sigma    = "σ",
    Tau      = "Τ",
    tau      = "τ",
    Upsilon  = "Υ",
    upsilon  = "υ",
    Phi      = "Φ",
    phi      = "φ",
    Chi      = "Χ",
    chi      = "χ",
    Psi      = "Ψ",
    psi      = "ψ",
    Omega    = "Ω",
    omega    = "ω",

    -- other letters
    CC       = "ℂ",
    NN       = "ℕ",
    QQ       = "ℚ",
    RR       = "ℝ",
    ZZ       = "ℤ",

    -- symbols
    infinity = "∞",
    arrow    = "→",
    times    = "×",
    dot      = "⋅",
    dots     = "…",
    approx   = "≈",
    degree   = "°",
    slash    = "/",
    ["in"]   = "∈",
}

vim.treesitter.query.add_directive("jhk-typst-set-symbol-conceal!", function(match, pattern, source, predicate, metadata)
    local id = predicate[2]
    local node = match[id]
    if not node then
        return
    end


    if not metadata[id] then
        metadata[id] = {}
    end
    local text = vim.treesitter.get_node_text(node, source)

    metadata[id].conceal = typst_symbol_names[text]
end, {})
-- }}}

-- Only select n initial characters of a node {{{
vim.treesitter.query.add_directive("jhk-set-length!", function(match, pattern, source, predicate, metadata)
    local id = predicate[2]
    local node = match[id]
    if not node then
        return
    end

    if not metadata[id] then
        metadata[id] = {}
    end
    if not metadata[id].range then
        local srow, scol, erow, ecol = vim.treesitter.get_node_range(node)
        metadata[id].range = { srow, scol, erow, ecol }
    end
    metadata[id].range[4] = metadata[id].range[2] + tonumber(predicate[3])
end, {})
-- }}}
