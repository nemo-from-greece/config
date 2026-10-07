-- Ported from Obsidian LaTeX Suite (data.json) to LuaSnip.
-- Requires VimTeX (see tex_utils.lua) for math-zone detection.
-- Load with: require("luasnip").add_snippets("tex", require("tex"))
--
-- Tabstop numbering note: LaTeX Suite's own engine visits $0, $1, $2... in
-- plain ascending order (0 first). LuaSnip reserves index 0 as the special
-- "final" stop, visited LAST regardless of where it sits. So throughout this
-- file, wherever the original snippet had more than one stop, the numbers
-- are shifted: the first thing you should fill in is i(1), i(2), etc., and
-- whichever original stop was meant to be filled last becomes i(0).

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta

local tex = require("tex_utils") -- in_mathzone / in_text / in_env

-- ===== conditions =====================================================

local function math()
  return tex.in_mathzone()
end
local function txt()
  return tex.in_text()
end

-- mirrors LaTeX Suite's "don't re-expand if already preceded by a backslash"
-- guard used on its ${GREEK}/${SYMBOL}/trig-function regex snippets
local function math_no_bs(line_to_cursor, matched_trigger)
  local before = line_to_cursor:sub(1, #line_to_cursor - #matched_trigger)
  return tex.in_mathzone() and before:sub(-1) ~= "\\"
end

-- visual-selection dynamic node, for the U/O/B/C/K/S wrap snippets
-- (requires store_selection_keys to be set in your luasnip setup{})
local function visual(_, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else
    return sn(nil, i(1))
  end
end

local function auto(trig, opts)
  opts = opts or {}
  opts.trig = trig
  opts.snippetType = opts.snippetType or "autosnippet"
  opts.wordTrig = opts.wordTrig or false
  return opts
end

local snippets = {}
local function add(snip)
  table.insert(snippets, snip)
end

-- ===== math mode / display math ========================================

add(s(auto("mk", { condition = txt }), { t("$"), i(1), t("$"), i(0) }))
add(s(auto("dm", { condition = txt, wordTrig = true }), { t({ "$$", "" }), i(1), t({ "", "$$" }), i(0) }))
-- no math condition: you write plenty of \begin{...} outside math zones
-- (document, itemize, figure, etc.) so this should fire everywhere.
-- env name is filled first (i(1)), body second (i(0), the exit stop);
-- the f() mirrors whatever you type for the env name into \end{...}
add(s(
  auto("beg"),
  fmta("\\begin{<>}\n\t<>\n\\end{<>}", { i(1), i(0), f(function(a)
    return a[1]
  end, { 1 }) })
))

-- default document preamble. Manual trigger (not autosnippet) since it's a
-- big block you don't want firing by accident. Adjust the package list to
-- match what you actually use.
add(s(
  auto("template", { condition = txt, snippetType = "snippet", wordTrig = true }),
  fmta(
    [[\documentclass[<>]{<>}

\usepackage{graphicx, svg} % Used for inserting images
\usepackage{longtable, booktabs, multirow, multicol}
\usepackage{pgfplots, pgfplotstable}
\usepackage{hyperref}
\usepackage{amsmath}
\pgfplotsset{compat=1.18}

\begin{document}

<>

\end{document}]],
    { i(1, "12pt"), i(2, "article"), i(0) }
  )
))

add(s(
  auto("plot", { condition = txt, snippetType = "snippet", wordTrig = true }),
  fmta(
    [[
\begin{figure*}[h!]
  \centering
  \begin{tikzpicture}
    \begin{<>}[
      title={<>},
      xlabel={<>},
      ylabel={<>},
      legend pos=outer north east,
      grid=both
    ]
      <>
    \end{<>}
  \end{tikzpicture}
\end{figure*}
    ]],
    { i(1, "axis"), i(2), i(3), i(4), i(0), f(function(a)
      return a[1]
    end, { 1 }) }
  )
))

-- ===== Greek letters (short forms) =====================================

local greek_short = {
  { "@a", "alpha" },
  { "@b", "beta" },
  { "@g", "gamma" },
  { "@G", "Gamma" },
  { "@d", "delta" },
  { "@D", "Delta" },
  { "@e", "epsilon" },
  { ":e", "varepsilon" },
  { "@z", "zeta" },
  { "@t", "theta" },
  { "@T", "Theta" },
  { ":t", "vartheta" },
  { "@i", "iota" },
  { "@k", "kappa" },
  { "@l", "lambda" },
  { "@L", "Lambda" },
  { "@s", "sigma" },
  { "@S", "Sigma" },
  { "@u", "upsilon" },
  { "@U", "Upsilon" },
  { "@o", "omega" },
  { "@O", "Omega" },
  { "ome", "omega" },
  { "Ome", "Omega" },
}
for _, p in ipairs(greek_short) do
  add(s(auto(p[1], { condition = math }), { t("\\" .. p[2]) }))
end

-- ===== text environment =================================================

add(s(auto("text", { condition = math }), fmta("\\text{<>}<>", { i(1), i(0) })))
add(s(auto('""', { condition = math }), fmta("\\text{<>}<>", { i(1), i(0) })))

-- ===== basic operations =================================================

add(s(auto("sr", { condition = math }), { t("^{2}") }))
add(s(auto("cb", { condition = math }), { t("^{3}") }))
add(s(auto("rd", { condition = math }), fmta("^{<>}<>", { i(1), i(0) })))
add(s(auto("_", { condition = math }), fmta("_{<>}<>", { i(1), i(0) })))
add(s(auto("sts", { condition = math }), fmta("_\\text{<>}", { i(0) })))
add(s(auto("sq", { condition = math }), fmta("\\sqrt{ <> }<>", { i(1), i(0) })))
add(s(auto("//", { condition = math }), fmta("\\frac{<>}{<>}<>", { i(1), i(2), i(0) })))
add(s(auto("ee", { condition = math }), fmta("e^{ <> }<>", { i(1), i(0) })))
add(s(auto("invs", { condition = math }), { t("^{-1}") }))
-- "smart" fraction: if math immediately precedes /, pull it into the
-- numerator automatically (mirrors LaTeX Suite's auto-fraction). Falls
-- through to the plain "/" above when nothing qualifying precedes it
-- (e.g. after a space, "+", "=", etc.).
add(s(
  auto("([%w_%^\\{}]+)/", { condition = math, regTrig = true, priority = 2000 }),
  { f(function(_, snip)
    return "\\frac{" .. snip.captures[1] .. "}{"
  end), i(0), t("}") }
))
add(s(
  auto("(%b())/", { condition = math, regTrig = true, priority = 2000 }),
  { f(function(_, snip)
    return "\\frac{" .. snip.captures[1] .. "}{"
  end), i(0), t("}") }
))
add(s(
  auto("(%b[])/", { condition = math, regTrig = true, priority = 2000 }),
  { f(function(_, snip)
    return "\\frac{" .. snip.captures[1] .. "}{"
  end), i(0), t("}") }
))
add(s(
  auto("(%b{})/", { condition = math, regTrig = true, priority = 2000 }),
  { f(function(_, snip)
    return "\\frac{" .. snip.captures[1] .. "}{"
  end), i(0), t("}") }
))

-- auto letter subscript: a2 -> a_{2}
-- %f[%a] is a "frontier" assertion: it only matches where the previous
-- character is NOT a letter, i.e. the letter has to be standalone. This is
-- what stops "1!=2" (-> "1\neq2") from turning into "1\ne q_{2}": the "q" in
-- "\neq" is preceded by another letter ("e"), so the frontier fails and it's
-- left alone. Same idea covers "sin2", "cos3", etc.
add(s(
  auto("%f[%a](%a)(%d)", { condition = math, regTrig = true, priority = 100 }),
  { f(function(_, snip)
    return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
  end) }
))

-- two-digit version: a12 -> a_{12}
add(s(
  auto("%f[%a](%a)_?(%d%d)", { condition = math, regTrig = true }),
  { f(function(_, snip)
    return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
  end) }
))

add(s(auto("conj", { condition = math }), { t("^{*}") }))
add(s(auto("Re", { condition = math }), { t("\\mathrm{Re}") }))
add(s(auto("Im", { condition = math }), { t("\\mathrm{Im}") }))
add(s(auto("bf", { condition = math }), fmta("\\mathbf{<>}", { i(0) })))
add(s(auto("rm", { condition = math }), fmta("\\mathrm{<>}<>", { i(1), i(0) })))
add(s(auto("scr", { condition = math }), fmta("\\mathscr{<>}<>", { i(1), i(0) })))

-- linear algebra
add(s(auto("trace", { condition = math }), { t("\\mathrm{Tr}") }))

-- ===== accents on a single letter: ahat -> \hat{a} etc. =================

local accents = {
  { "hat", "\\hat{%s}" },
  { "bar", "\\bar{%s}" },
  { "tilde", "\\tilde{%s}" },
  { "und", "\\underline{%s}" },
  { "vec", "\\vec{%s}" },
}
for _, p in ipairs(accents) do
  add(s(
    auto("(%a)" .. p[1], { condition = math, regTrig = true }),
    { f(function(_, snip)
      return string.format(p[2], snip.captures[1])
    end) }
  ))
end
add(s(
  auto("(%a)dot", { condition = math, regTrig = true, priority = 100 }),
  { f(function(_, snip)
    return "\\dot{" .. snip.captures[1] .. "}"
  end) }
))
add(s(
  auto("(%a)ddot", { condition = math, regTrig = true, priority = 2000 }),
  { f(function(_, snip)
    return "\\ddot{" .. snip.captures[1] .. "}"
  end) }
))
-- bold via trailing/leading comma-period: a,. or a.,  -> \mathbf{a}
add(s(
  auto("(%a),%.", { condition = math, regTrig = true }),
  { f(function(_, snip)
    return "\\mathbf{" .. snip.captures[1] .. "}"
  end) }
))
add(s(
  auto("(%a)%.,", { condition = math, regTrig = true }),
  { f(function(_, snip)
    return "\\mathbf{" .. snip.captures[1] .. "}"
  end) }
))

-- non-regex (bare word) accent versions, need an explicit argument
add(s(auto("hat", { condition = math }), fmta("\\hat{<>}<>", { i(1), i(0) })))
add(s(auto("bar", { condition = math }), fmta("\\bar{<>}<>", { i(1), i(0) })))
add(s(auto("dot", { condition = math, priority = 100 }), fmta("\\dot{<>}<>", { i(1), i(0) })))
add(s(auto("ddot", { condition = math }), fmta("\\ddot{<>}<>", { i(1), i(0) })))
add(s(auto("cdot", { condition = math }), { t("\\cdot") }))
add(s(auto("tilde", { condition = math }), fmta("\\tilde{<>}<>", { i(1), i(0) })))
add(s(auto("und", { condition = math }), fmta("\\underline{<>}<>", { i(1), i(0) })))
add(s(auto("vec", { condition = math }), fmta("\\vec{<>}<>", { i(1), i(0) })))

-- accented + digit subscript: \hat{a}2 -> \hat{a}_{2}  (also \vec, \mathbf)
for _, cmd in ipairs({ "hat", "vec", "mathbf" }) do
  add(s(auto("\\\\" .. cmd .. "{(%a)}(%d)", { condition = math, regTrig = true }), {
    f(function(_, snip)
      return "\\" .. cmd .. "{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end),
  }))
end

-- ===== symbols ===========================================================

local symbol_map = {
  { "ooo", "\\infty" },
  { "sum", "\\sum" },
  { "prod", "\\prod" },
  { "+-", "\\pm" },
  { "-+", "\\mp" },
  { "...", "\\dots" },
  { "nabl", "\\nabla" },
  { "del", "\\nabla" },
  { "xx", "\\times" },
  { "**", "\\cdot" },
  { "para", "\\parallel" },
  { "===", "\\equiv" },
  { "!=", "\\neq" },
  { ">=", "\\geq" },
  { "<=", "\\leq" },
  { ">>", "\\gg" },
  { "<<", "\\ll" },
  { "simm", "\\sim" },
  { "sim=", "\\simeq" },
  { "prop", "\\propto" },
  { "<->", "\\leftrightarrow " },
  { "->", "\\to" },
  { "!>", "\\mapsto" },
  { "=>", "\\implies" },
  { "=<", "\\impliedby" },
  { "and", "\\cap" },
  { "orr", "\\cup" },
  { "inn", "\\in" },
  { "notin", "\\not\\in" },
  { [[\\\\]], "\\setminus" },
  { "sub=", "\\subseteq" },
  { "sup=", "\\supseteq" },
  { "eset", "\\emptyset" },
  { "dne", "\\nexists" },
  { "LL", "\\mathcal{L}" },
  { "HH", "\\mathcal{H}" },
  { "CC", "\\mathbb{C}" },
  { "RR", "\\mathbb{R}" },
  { "ZZ", "\\mathbb{Z}" },
  { "NN", "\\mathbb{N}" },
}
for _, p in ipairs(symbol_map) do
  add(s(auto(p[1], { condition = math }), { t(p[2]) }))
end
add(s(auto("set", { condition = math }), fmta("\\{ <> \\}<>", { i(1), i(0) })))
add(s(auto([[e\\xi sts]], { condition = math, priority = 2000 }), { t("\\exists") }))

add(
  s(
    auto("\\\\sum", { condition = math, snippetType = "snippet" }),
    fmta("\\sum_{<>=<>}^{<>} <>", { i(1, "i"), i(2, "1"), i(3, "N"), i(0) })
  )
)
add(
  s(
    auto("\\\\prod", { condition = math, snippetType = "snippet" }),
    fmta("\\prod_{<>=<>}^{<>} <>", { i(1, "i"), i(2, "1"), i(3, "N"), i(0) })
  )
)
add(s(auto("lim", { condition = math }), fmta("\\lim_{ <> \\to <> } <>", { i(1, "n"), i(2, "\\infty"), i(0) })))

-- ===== derivatives & integrals ==========================================

add(
  s(
    auto("par", { condition = math, snippetType = "snippet" }),
    fmta("\\frac{ \\partial <> }{ \\partial <> } <>", { i(1, "y"), i(2, "x"), i(0) })
  )
)
add(s(auto("pa(%a)(%a)", { condition = math, regTrig = true, snippetType = "snippet" }), {
  f(function(_, snip)
    return "\\frac{ \\partial " .. snip.captures[1] .. " }{ \\partial " .. snip.captures[2] .. " } "
  end),
}))
add(s(auto("ddt", { condition = math }), { t("\\frac{d}{dt} ") }))

add(s(auto("int", { condition = math_no_bs, priority = 100 }), { t("\\int") }))
add(
  s(
    auto("\\\\int", { condition = math, snippetType = "snippet" }),
    fmta("\\int <> \\, d<> <>", { i(1), i(2, "x"), i(0) })
  )
)
add(
  s(
    auto("dint", { condition = math }),
    fmta("\\int_{<>}^{<>} <> \\, d<> <>", { i(1, "0"), i(2, "1"), i(3), i(4, "x"), i(0) })
  )
)
add(s(auto("oint", { condition = math }), { t("\\oint") }))
add(s(auto("iint", { condition = math }), { t("\\iint") }))
add(s(auto("iiint", { condition = math }), { t("\\iiint") }))
add(s(auto("oinf", { condition = math }), fmta("\\int_{0}^{\\infty} <> \\, d<> <>", { i(1), i(2, "x"), i(0) })))
add(s(auto("infi", { condition = math }), fmta("\\int_{-\\infty}^{\\infty} <> \\, d<> <>", { i(1), i(2, "x"), i(0) })))

-- ===== trig / log / exp / det (backslash-prefixed, own word, math only) ===

local prefix_words = {
  "arcsin",
  "sin",
  "arccos",
  "cos",
  "arctan",
  "tan",
  "csc",
  "sec",
  "cot",
  "sinh",
  "cosh",
  "tanh",
  "coth",
  "exp",
  "log",
  "ln",
  "det",
}
for _, w in ipairs(prefix_words) do
  add(s(auto(w, { condition = math_no_bs, wordTrig = true }), { t("\\" .. w .. " ") }))
end

-- ===== physics ===========================================================

add(s(auto("kbt", { condition = math }), { t("k_{B}T") }))
add(s(auto("msun", { condition = math }), { t("M_{\\odot}") }))
add(s(auto("deg", { condition = math }), { t("\\degree") }))

-- ===== environments =======================================================

local envs = { "pmatrix", "bmatrix", "Bmatrix", "vmatrix", "Vmatrix", "matrix" }
local env_trig =
  { pmatrix = "pmat", bmatrix = "bmat", Bmatrix = "Bmat", vmatrix = "vmat", Vmatrix = "Vmat", matrix = "matrix" }
for _, env in ipairs(envs) do
  local trig = env_trig[env]
  -- block/multi-line version (was "MA")
  add(
    s(
      auto(trig, { condition = math, priority = 100 }),
      fmta("\\begin{" .. env .. "}\n<>\n\\end{" .. env .. "}", { i(0) })
    )
  )
end
add(s(auto("cases", { condition = math }), fmta("\\begin{cases}\n<>\n\\end{cases}", { i(0) })))
add(s(auto("align", { condition = math }), fmta("\\begin{align}\n<>\n\\end{align}", { i(0) })))
add(s(auto("array", { condition = math }), fmta("\\begin{array}\n<>\n\\end{array}", { i(0) })))

-- ===== brackets ============================================================

add(s(auto("avg", { condition = math }), fmta("\\langle <> \\rangle <>", { i(1), i(0) })))
add(s(auto("norm", { condition = math, priority = 2000 }), fmta("\\lvert <> \\rvert <>", { i(1), i(0) })))
add(s(auto("Norm", { condition = math, priority = 2000 }), fmta("\\lVert <> \\rVert <>", { i(1), i(0) })))
add(s(auto("ceil", { condition = math }), fmta("\\lceil <> \\rceil <>", { i(1), i(0) })))
add(s(auto("floor", { condition = math }), fmta("\\lfloor <> \\rfloor <>", { i(1), i(0) })))
add(s(auto("mod", { condition = math }), fmta("|<>|<>", { i(1), i(0) })))

-- ( [ { : wrap visual selection if there is one, otherwise plain tabstop pair
add(s(auto("(", { condition = math }), {
  d(1, function(_, parent)
    if #parent.snippet.env.LS_SELECT_RAW > 0 then
      return sn(nil, fmta("(<>)", { t(parent.snippet.env.LS_SELECT_RAW) }))
    end
    return sn(nil, fmta("(<>)<>", { i(1), i(0) }))
  end, {}),
}))
add(s(auto("[", { condition = math }), {
  d(1, function(_, parent)
    if #parent.snippet.env.LS_SELECT_RAW > 0 then
      return sn(nil, fmta("[<>]", { t(parent.snippet.env.LS_SELECT_RAW) }))
    end
    return sn(nil, fmta("[<>]<>", { i(1), i(0) }))
  end, {}),
}))
add(s(auto("{", { condition = math }), {
  d(1, function(_, parent)
    if #parent.snippet.env.LS_SELECT_RAW > 0 then
      return sn(nil, fmta("{<>}", { t(parent.snippet.env.LS_SELECT_RAW) }))
    end
    return sn(nil, fmta("{<>}<>", { i(1), i(0) }))
  end, {}),
}))

add(s(auto("lr(", { condition = math }), fmta("\\left( <> \\right) <>", { i(1), i(0) })))
add(s(auto("lr{", { condition = math }), fmta("\\left\\{ <> \\right\\} <>", { i(1), i(0) })))
add(s(auto("lr[", { condition = math }), fmta("\\left[ <> \\right] <>", { i(1), i(0) })))
add(s(auto("lr|", { condition = math }), fmta("\\left| <> \\right| <>", { i(1), i(0) })))
add(s(auto("lra", { condition = math }), { t("\\left< "), i(1), t(" \\right> "), i(0) }))

-- ===== misc ================================================================

add(s(auto("box", { condition = math, priority = 100 }), fmta("\\boxed{<>}", { i(0) })))

return snippets
