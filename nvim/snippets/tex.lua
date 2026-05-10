-- snippets/tex.lua
-- ~/.config/nvim/snippets/tex.lua
--
-- Direct port of your Obsidian LaTeX Suite data.json snippets.
-- Obsidian option flags:
--   t  = text mode only (outside math)
--   m  = any math mode (inline OR block) — shorthand for M+n
--   M  = block math only  ($$ ... $$ or \[ ... \] environments)
--   n  = inline math only ($ ... $)
--   A  = autosnippet (fires on typing, no Tab needed)
--   r  = regex trigger
--   v  = visual mode only (single-char trigger wrapping selection)
--   w  = word boundary required
--
-- All three math conditions are implemented via VimTeX syntax groups.
-- ─────────────────────────────────────────────────────────────────────────────

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

-- ── Conditions ───────────────────────────────────────────────────────────────
-- VimTeX syntax groups:
--   texMathZoneX   = $...$   (inline)
--   texMathZoneXX  = $$...$$ (block/display)
--   texMathZoneEnv = \begin{equation} etc. (also block/display)
local function get_syn_name()
  return vim.fn.synIDattr(vim.fn.synID(vim.fn.line("."), vim.fn.col(".") - 1, 1), "name")
end

local in_inline_math = function()
  -- n: only inside $...$
  local syn = get_syn_name()
  return syn == "texMathZoneX" or syn == "texMathZoneXi"
end

local in_block_math = function()
  -- M: only inside $$...$$ or math environments
  local syn = get_syn_name()
  return syn == "texMathZoneXX"
    or syn == "texMathZoneXXi"
    or syn:find("texMathZoneEnv") ~= nil
    or syn:find("texMathZone") ~= nil and not in_inline_math()
end

local in_mathzone = function()
  -- m: any math (inline or block)
  local ok, r = pcall(vim.fn["vimtex#syntax#in_mathzone"])
  return ok and r == 1
end

local in_text = function()
  return not in_mathzone()
end

-- Shorthand opts tables
local M_any = { condition = in_mathzone, show_condition = in_mathzone } -- m
local M_block = { condition = in_block_math, show_condition = in_block_math } -- M
local M_inl = { condition = in_inline_math, show_condition = in_inline_math } -- n
local T = { condition = in_text, show_condition = in_text } -- t

-- Keep a short alias for the common "any math" case
local M = M_any

-- ── Visual selection helper ───────────────────────────────────────────────────
-- Used for snippets that wrap selected text (U, O, B, C, K, S, brackets)
local get_visual = function(_, parent)
  local sel = parent.snippet.env.SELECT_RAW
  if sel and #sel > 0 then
    return sn(nil, { i(1, sel) })
  else
    return sn(nil, { i(1) })
  end
end

-- ── Expanded ${GREEK} / ${SYMBOL} variables (from snippetVariables) ──────────
local GREEK = "alpha|beta|gamma|Gamma|delta|Delta|epsilon|varepsilon|zeta|eta|"
  .. "theta|vartheta|Theta|iota|kappa|lambda|Lambda|mu|nu|xi|omicron|"
  .. "pi|rho|varrho|sigma|Sigma|tau|upsilon|Upsilon|phi|varphi|Phi|chi|"
  .. "psi|omega|Omega"

local SYMBOL = "parallel|perp|partial|nabla|hbar|ell|infty|oplus|ominus|otimes|"
  .. "oslash|square|star|dagger|vee|wedge|subseteq|subset|supseteq|"
  .. "supset|emptyset|exists|nexists|forall|implies|impliedby|iff|"
  .. "setminus|neg|lor|land|bigcup|bigcap|cdot|times|simeq|approx"

local MORE = "leq|geq|neq|gg|ll|equiv|sim|propto|rightarrow|leftarrow|"
  .. "Rightarrow|Leftarrow|leftrightarrow|to|mapsto|cap|cup|in|sum|"
  .. "prod|exp|ln|log|det|dots|vdots|ddots|pm|mp|int|iint|iiint|oint"

-- =============================================================================
--  TEXT-MODE SNIPPETS  (options contain "t")
-- =============================================================================
local text_snippets = {

  -- mk  →  $|$                                              tA
  s({ trig = "mk", snippetType = "autosnippet" }, fmta("$<>$", { i(1) }), T),

  -- dm  →  $$\n|\n$$                                        tAw
  s({ trig = "dm", wordTrig = true, snippetType = "autosnippet" }, fmta("$$\n<>\n$$", { i(1) }), T),
}

-- =============================================================================
--  MATH-MODE SNIPPETS  (options contain "m", "M", or "n")
-- =============================================================================
local math_snippets = {

  -- ── Generic environment  (mA) ─────────────────────────────────────────────
  s({ trig = "beg", snippetType = "autosnippet" }, fmta("\\begin{<>}\n<>\n\\end{<>}", { i(1), i(2), rep(1) }), M),

  -- ── Greek letters  (@letter → \GreekLetter)  (mA) ────────────────────────
  s({ trig = "@a", snippetType = "autosnippet" }, { t("\\alpha") }, M),
  s({ trig = "@b", snippetType = "autosnippet" }, { t("\\beta") }, M),
  s({ trig = "@g", snippetType = "autosnippet" }, { t("\\gamma") }, M),
  s({ trig = "@G", snippetType = "autosnippet" }, { t("\\Gamma") }, M),
  s({ trig = "@d", snippetType = "autosnippet" }, { t("\\delta") }, M),
  s({ trig = "@D", snippetType = "autosnippet" }, { t("\\Delta") }, M),
  s({ trig = "@e", snippetType = "autosnippet" }, { t("\\epsilon") }, M),
  s({ trig = ":e", snippetType = "autosnippet" }, { t("\\varepsilon") }, M),
  s({ trig = "@z", snippetType = "autosnippet" }, { t("\\zeta") }, M),
  s({ trig = "@t", snippetType = "autosnippet" }, { t("\\theta") }, M),
  s({ trig = "@T", snippetType = "autosnippet" }, { t("\\Theta") }, M),
  s({ trig = ":t", snippetType = "autosnippet" }, { t("\\vartheta") }, M),
  s({ trig = "@i", snippetType = "autosnippet" }, { t("\\iota") }, M),
  s({ trig = "@k", snippetType = "autosnippet" }, { t("\\kappa") }, M),
  s({ trig = "@l", snippetType = "autosnippet" }, { t("\\lambda") }, M),
  s({ trig = "@L", snippetType = "autosnippet" }, { t("\\Lambda") }, M),
  s({ trig = "@s", snippetType = "autosnippet" }, { t("\\sigma") }, M),
  s({ trig = "@S", snippetType = "autosnippet" }, { t("\\Sigma") }, M),
  s({ trig = "@u", snippetType = "autosnippet" }, { t("\\upsilon") }, M),
  s({ trig = "@U", snippetType = "autosnippet" }, { t("\\Upsilon") }, M),
  s({ trig = "@o", snippetType = "autosnippet" }, { t("\\omega") }, M),
  s({ trig = "@O", snippetType = "autosnippet" }, { t("\\Omega") }, M),
  s({ trig = "ome", snippetType = "autosnippet" }, { t("\\omega") }, M),
  s({ trig = "Ome", snippetType = "autosnippet" }, { t("\\Omega") }, M),

  -- ── Text environment  (mA) ────────────────────────────────────────────────
  s({ trig = "text", snippetType = "autosnippet" }, fmta("\\text{<>}", { i(1) }), M),
  s({ trig = '"', snippetType = "autosnippet" }, fmta("\\text{<>}", { i(1) }), M),

  -- ── Basic operations  (mA) ───────────────────────────────────────────────
  s({ trig = "sr", snippetType = "autosnippet" }, { t("^{2}") }, M),
  s({ trig = "cb", snippetType = "autosnippet" }, { t("^{3}") }, M),
  s({ trig = "rd", snippetType = "autosnippet" }, fmta("^{<>}", { i(1) }), M),
  s({ trig = "_", snippetType = "autosnippet" }, fmta("_{<>}", { i(1) }), M),
  s({ trig = "sts", snippetType = "autosnippet" }, fmta("_\\text{<>}", { i(1) }), M),
  s({ trig = "sq", snippetType = "autosnippet" }, fmta("\\sqrt{ <> }", { i(1) }), M),
  s({ trig = "//", snippetType = "autosnippet" }, fmta("\\frac{<>}{<>}", { i(1), i(2) }), M),
  s({ trig = "ee", snippetType = "autosnippet" }, fmta("e^{ <> }", { i(1) }), M),
  s({ trig = "invs", snippetType = "autosnippet" }, { t("^{-1}") }, M),
  s({ trig = "conj", snippetType = "autosnippet" }, { t("^{*}") }, M),
  s({ trig = "Re", snippetType = "autosnippet" }, { t("\\mathrm{Re}") }, M),
  s({ trig = "Im", snippetType = "autosnippet" }, { t("\\mathrm{Im}") }, M),
  s({ trig = "bf", snippetType = "autosnippet" }, fmta("\\mathbf{<>}", { i(1) }), M),
  s({ trig = "rm", snippetType = "autosnippet" }, fmta("\\mathrm{<>}", { i(1) }), M),

  -- ── Linear algebra  (mA / rmA) ───────────────────────────────────────────
  s(
    { trig = "([^\\\\])(det)", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return snip.captures[1] .. "\\det"
    end) },
    M
  ),
  s({ trig = "trace", snippetType = "autosnippet" }, { t("\\mathrm{Tr}") }, M),

  -- ── Auto letter subscript  (rmA, priority -1) ────────────────────────────
  s(
    { trig = "([A-Za-z])(%d)", regTrig = true, snippetType = "autosnippet", priority = 999 },
    { f(function(_, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end) },
    M
  ),

  -- ([^\\])(exp|log|ln)  →  add backslash                    rmA
  s(
    { trig = "([^\\\\])(exp|log|ln)", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return snip.captures[1] .. "\\" .. snip.captures[2]
    end) },
    M
  ),

  -- ── Accents with preceding letter  (rmA) ─────────────────────────────────
  s(
    { trig = "([a-zA-Z])hat", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\hat{" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "([a-zA-Z])bar", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\bar{" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "([a-zA-Z])dot", regTrig = true, snippetType = "autosnippet", priority = 999 },
    { f(function(_, snip)
      return "\\dot{" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "([a-zA-Z])ddot", regTrig = true, snippetType = "autosnippet", priority = 1001 },
    { f(function(_, snip)
      return "\\ddot{" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "([a-zA-Z])tilde", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\tilde{" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "([a-zA-Z])und", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\underline{" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "([a-zA-Z])vec", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\vec{" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  -- X,\.  or  X\.,  →  \mathbf{X}
  s(
    { trig = "([a-zA-Z]),\\.", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\mathbf{" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "([a-zA-Z])\\.,", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\mathbf{" .. snip.captures[1] .. "}"
    end) },
    M
  ),

  -- ── Standalone accents  (mA) ──────────────────────────────────────────────
  s({ trig = "hat", snippetType = "autosnippet" }, fmta("\\hat{<>}", { i(1) }), M),
  s({ trig = "bar", snippetType = "autosnippet" }, fmta("\\bar{<>}", { i(1) }), M),
  s({ trig = "dot", snippetType = "autosnippet", priority = 999 }, fmta("\\dot{<>}", { i(1) }), M),
  s({ trig = "ddot", snippetType = "autosnippet" }, fmta("\\ddot{<>}", { i(1) }), M),
  s({ trig = "cdot", snippetType = "autosnippet" }, { t("\\cdot") }, M),
  s({ trig = "tilde", snippetType = "autosnippet" }, fmta("\\tilde{<>}", { i(1) }), M),
  s({ trig = "und", snippetType = "autosnippet" }, fmta("\\underline{<>}", { i(1) }), M),
  s({ trig = "vec", snippetType = "autosnippet" }, fmta("\\vec{<>}", { i(1) }), M),

  -- ── More subscript variants  (rmA) ───────────────────────────────────────
  s(
    { trig = "([A-Za-z])_(%d%d)", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end) },
    M
  ),
  s(
    { trig = "\\hat{([A-Za-z])}(%d)", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\hat{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end) },
    M
  ),
  s(
    { trig = "\\vec{([A-Za-z])}(%d)", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\vec{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end) },
    M
  ),
  s(
    { trig = "\\mathbf{([A-Za-z])}(%d)", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\mathbf{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end) },
    M
  ),

  -- ── Named subscript shorthands  (mA) ─────────────────────────────────────
  s({ trig = "xnn", snippetType = "autosnippet" }, { t("x_{n}") }, M),
  s({ trig = "\\xii", snippetType = "autosnippet", priority = 1001 }, { t("x_{i}") }, M),
  s({ trig = "xjj", snippetType = "autosnippet" }, { t("x_{j}") }, M),
  s({ trig = "xp1", snippetType = "autosnippet" }, { t("x_{n+1}") }, M),
  s({ trig = "ynn", snippetType = "autosnippet" }, { t("y_{n}") }, M),
  s({ trig = "yii", snippetType = "autosnippet" }, { t("y_{i}") }, M),
  s({ trig = "yjj", snippetType = "autosnippet" }, { t("y_{j}") }, M),

  -- ── Symbols  (mA) ────────────────────────────────────────────────────────
  s({ trig = "ooo", snippetType = "autosnippet" }, { t("\\infty") }, M),
  s({ trig = "sum", snippetType = "autosnippet" }, { t("\\sum") }, M),
  s({ trig = "prod", snippetType = "autosnippet" }, { t("\\prod") }, M),
  -- \sum  (tab-triggered)  →  \sum_{i=1}^{N} |
  s({ trig = "\\sum" }, fmta("\\sum_{<>=<>}^{<>} <>", { i(1, "i"), i(2, "1"), i(3, "N"), i(4) }), M),
  -- \prod  (tab-triggered)  →  \prod_{i=1}^{N} |
  s({ trig = "\\prod" }, fmta("\\prod_{<>=<>}^{<>} <>", { i(1, "i"), i(2, "1"), i(3, "N"), i(4) }), M),
  -- lim  →  \lim_{ n \to \infty } |
  s(
    { trig = "lim", snippetType = "autosnippet" },
    fmta("\\lim_{ <> \\to <> } <>", { i(1, "n"), i(2, "\\infty"), i(3) }),
    M
  ),
  s({ trig = "+-", snippetType = "autosnippet" }, { t("\\pm") }, M),
  s({ trig = "-+", snippetType = "autosnippet" }, { t("\\mp") }, M),
  s({ trig = "...", snippetType = "autosnippet" }, { t("\\dots") }, M),
  s({ trig = "nabl", snippetType = "autosnippet" }, { t("\\nabla") }, M),
  s({ trig = "del", snippetType = "autosnippet" }, { t("\\nabla") }, M),
  s({ trig = "xx", snippetType = "autosnippet" }, { t("\\times") }, M),
  s({ trig = "**", snippetType = "autosnippet" }, { t("\\cdot") }, M),
  s({ trig = "para", snippetType = "autosnippet" }, { t("\\parallel") }, M),

  -- ── Relations  (mA) ──────────────────────────────────────────────────────
  s({ trig = "===", snippetType = "autosnippet" }, { t("\\equiv") }, M),
  s({ trig = "!=", snippetType = "autosnippet" }, { t("\\neq") }, M),
  s({ trig = ">=", snippetType = "autosnippet" }, { t("\\geq") }, M),
  s({ trig = "<=", snippetType = "autosnippet" }, { t("\\leq") }, M),
  s({ trig = ">>", snippetType = "autosnippet" }, { t("\\gg") }, M),
  s({ trig = "<<", snippetType = "autosnippet" }, { t("\\ll") }, M),
  s({ trig = "simm", snippetType = "autosnippet" }, { t("\\sim") }, M),
  s({ trig = "sim=", snippetType = "autosnippet" }, { t("\\simeq") }, M),
  s({ trig = "prop", snippetType = "autosnippet" }, { t("\\propto") }, M),

  -- ── Arrows  (mA) ─────────────────────────────────────────────────────────
  s({ trig = "<->", snippetType = "autosnippet" }, { t("\\leftrightarrow ") }, M),
  s({ trig = "->", snippetType = "autosnippet" }, { t("\\to") }, M),
  s({ trig = "!>", snippetType = "autosnippet" }, { t("\\mapsto") }, M),
  s({ trig = "=>", snippetType = "autosnippet" }, { t("\\implies") }, M),
  s({ trig = "=<", snippetType = "autosnippet" }, { t("\\impliedby") }, M),

  -- ── Sets  (mA) ───────────────────────────────────────────────────────────
  s({ trig = "and", snippetType = "autosnippet" }, { t("\\cap") }, M),
  s({ trig = "orr", snippetType = "autosnippet" }, { t("\\cup") }, M),
  s({ trig = "inn", snippetType = "autosnippet" }, { t("\\in") }, M),
  s({ trig = "notin", snippetType = "autosnippet" }, { t("\\not\\in") }, M),
  s({ trig = "\\\\\\\\", snippetType = "autosnippet" }, { t("\\setminus") }, M),
  s({ trig = "sub=", snippetType = "autosnippet" }, { t("\\subseteq") }, M),
  s({ trig = "sup=", snippetType = "autosnippet" }, { t("\\supseteq") }, M),
  s({ trig = "eset", snippetType = "autosnippet" }, { t("\\emptyset") }, M),
  s({ trig = "set", snippetType = "autosnippet" }, fmta("\\{ <> \\}", { i(1) }), M),
  s({ trig = "exists", snippetType = "autosnippet" }, { t("\\exists") }, M),
  s({ trig = "dne", snippetType = "autosnippet" }, { t("\\nexists") }, M),

  -- ── Calligraphic / blackboard bold  (mA) ─────────────────────────────────
  s({ trig = "LL", snippetType = "autosnippet" }, { t("\\mathcal{L}") }, M),
  s({ trig = "HH", snippetType = "autosnippet" }, { t("\\mathcal{H}") }, M),
  s({ trig = "CC", snippetType = "autosnippet" }, { t("\\mathbb{C}") }, M),
  s({ trig = "RR", snippetType = "autosnippet" }, { t("\\mathbb{R}") }, M),
  s({ trig = "ZZ", snippetType = "autosnippet" }, { t("\\mathbb{Z}") }, M),
  s({ trig = "NN", snippetType = "autosnippet" }, { t("\\mathbb{N}") }, M),

  -- ── Auto-backslash before bare Greek / symbol words  (rmA) ───────────────
  -- e.g. typing "alpha" in math → "\alpha"  (only when not already after \)
  s(
    { trig = "([^\\\\])(" .. GREEK .. ")", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return snip.captures[1] .. "\\" .. snip.captures[2]
    end) },
    M
  ),
  s(
    { trig = "([^\\\\])(" .. SYMBOL .. ")", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return snip.captures[1] .. "\\" .. snip.captures[2]
    end) },
    M
  ),

  -- ── Auto-space after \Greek/\Symbol followed by a letter  (rmA) ──────────
  -- e.g.  \alphax  →  \alpha x
  s({
    trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. "|" .. MORE .. ")([A-Za-z])",
    regTrig = true,
    snippetType = "autosnippet",
  }, { f(function(_, snip)
    return "\\" .. snip.captures[1] .. " " .. snip.captures[2]
  end) }, M),

  -- ── Power / accent shorthands after \Greek / \Symbol  (rmA) ──────────────
  s(
    { trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") sr", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\" .. snip.captures[1] .. "^{2}"
    end) },
    M
  ),
  s(
    { trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") cb", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\" .. snip.captures[1] .. "^{3}"
    end) },
    M
  ),
  s(
    { trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") rd", regTrig = true, snippetType = "autosnippet" },
    d(1, function(_, snip)
      return sn(nil, { t("\\" .. snip.captures[1] .. "^{"), i(1), t("}") })
    end),
    M
  ),
  s(
    { trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") hat", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\hat{\\" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") dot", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\dot{\\" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") bar", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\bar{\\" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") vec", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\vec{\\" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") tilde", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\tilde{\\" .. snip.captures[1] .. "}"
    end) },
    M
  ),
  s(
    { trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") und", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\underline{\\" .. snip.captures[1] .. "}"
    end) },
    M
  ),

  -- ── Derivatives  (m tab-triggered, mA auto) ───────────────────────────────
  -- par  (tab)  →  \frac{ \partial y }{ \partial x }
  s({ trig = "par" }, fmta("\\frac{ \\partial <> }{ \\partial <> } <>", { i(1, "y"), i(2, "x"), i(3) }), M),
  -- pa[A-Za-z][A-Za-z]  (tab, regex)  →  \frac{∂a}{∂b}
  s({ trig = "pa([A-Za-z])([A-Za-z])", regTrig = true }, {
    f(function(_, snip)
      return "\\frac{ \\partial " .. snip.captures[1] .. " }{ \\partial " .. snip.captures[2] .. " } "
    end),
  }, M),
  -- ddt  →  \frac{d}{dt}                                    mA
  s({ trig = "ddt", snippetType = "autosnippet" }, { t("\\frac{d}{dt} ") }, M),

  -- ── Integrals  (mA / m tab) ───────────────────────────────────────────────
  -- ([^\\])int  →  ensure backslash before int               mA, priority -1
  s(
    { trig = "([^\\\\])int", regTrig = true, snippetType = "autosnippet", priority = 999 },
    { f(function(_, snip)
      return snip.captures[1] .. "\\int"
    end) },
    M
  ),
  -- \int  (tab)  →  \int | \, dx
  s({ trig = "\\int" }, fmta("\\int <> \\, d<> <>", { i(1), i(2, "x"), i(3) }), M),
  -- dint  →  \int_{0}^{1} | \, dx                           mA
  s(
    { trig = "dint", snippetType = "autosnippet" },
    fmta("\\int_{<>}^{<>} <> \\, d<> <>", { i(1, "0"), i(2, "1"), i(3), i(4, "x"), i(5) }),
    M
  ),
  s({ trig = "oint", snippetType = "autosnippet" }, { t("\\oint") }, M),
  s({ trig = "iint", snippetType = "autosnippet" }, { t("\\iint") }, M),
  s({ trig = "iiint", snippetType = "autosnippet" }, { t("\\iiint") }, M),
  -- oinf  →  \int_{0}^{\infty} | \, dx
  s(
    { trig = "oinf", snippetType = "autosnippet" },
    fmta("\\int_{0}^{\\infty} <> \\, d<> <>", { i(1), i(2, "x"), i(3) }),
    M
  ),
  -- infi  →  \int_{-\infty}^{\infty} | \, dx
  s(
    { trig = "infi", snippetType = "autosnippet" },
    fmta("\\int_{-\\infty}^{\\infty} <> \\, d<> <>", { i(1), i(2, "x"), i(3) }),
    M
  ),

  -- ── Trigonometry  (rmA) ──────────────────────────────────────────────────
  s(
    { trig = "([^\\\\])(arcsin|sin|arccos|cos|arctan|tan|csc|sec|cot)", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return snip.captures[1] .. "\\" .. snip.captures[2]
    end) },
    M
  ),
  -- add space after trig, skip h to allow sinh/cosh
  s({
    trig = "\\(arcsin|sin|arccos|cos|arctan|tan|csc|sec|cot)([A-Za-gi-z])",
    regTrig = true,
    snippetType = "autosnippet",
  }, { f(function(_, snip)
    return "\\" .. snip.captures[1] .. " " .. snip.captures[2]
  end) }, M),
  s(
    { trig = "\\(sinh|cosh|tanh|coth)([A-Za-z])", regTrig = true, snippetType = "autosnippet" },
    { f(function(_, snip)
      return "\\" .. snip.captures[1] .. " " .. snip.captures[2]
    end) },
    M
  ),

  -- ── Visual-selection operations  (mA) ─────────────────────────────────────
  -- Select text in visual mode, then type the trigger to wrap it.
  s({ trig = "U", snippetType = "autosnippet" }, fmta("\\underbrace{ <> }_{ <> }", { d(1, get_visual), i(2) }), M),
  s({ trig = "O", snippetType = "autosnippet" }, fmta("\\overbrace{ <> }^{ <> }", { d(1, get_visual), i(2) }), M),
  s({ trig = "B", snippetType = "autosnippet" }, fmta("\\underset{ <> }{ <> }", { i(1), d(2, get_visual) }), M),
  s({ trig = "C", snippetType = "autosnippet" }, fmta("\\cancel{ <> }", { d(1, get_visual) }), M),
  s({ trig = "K", snippetType = "autosnippet" }, fmta("\\cancelto{ <> }{ <> }", { i(1), d(2, get_visual) }), M),
  s({ trig = "S", snippetType = "autosnippet" }, fmta("\\sqrt{ <> }", { d(1, get_visual) }), M),

  -- ── Physics  (mA) ────────────────────────────────────────────────────────
  s({ trig = "kbt", snippetType = "autosnippet" }, { t("k_{B}T") }, M),
  s({ trig = "msun", snippetType = "autosnippet" }, { t("M_{\\odot}") }, M),
  s({ trig = "deg", snippetType = "autosnippet" }, { t("\\degree") }, M),

  -- ── Quantum mechanics  (mA) ───────────────────────────────────────────────
  s({ trig = "dag", snippetType = "autosnippet" }, { t("^{\\dagger}") }, M),
  s({ trig = "o+", snippetType = "autosnippet" }, { t("\\oplus ") }, M),
  s({ trig = "ox", snippetType = "autosnippet" }, { t("\\otimes ") }, M),
  s({ trig = "bra", snippetType = "autosnippet" }, fmta("\\bra{<>} <>", { i(1), i(2) }), M),
  s({ trig = "ket", snippetType = "autosnippet" }, fmta("\\ket{<>} <>", { i(1), i(2) }), M),
  s({ trig = "brk", snippetType = "autosnippet" }, fmta("\\braket{ <> | <> } <>", { i(1), i(2), i(3) }), M),
  s(
    { trig = "outer", snippetType = "autosnippet" },
    fmta("\\ket{<>} \\bra{<>} <>", { i(1, "\\psi"), rep(1), i(2) }),
    M
  ),

  -- ── Chemistry  (mA) ──────────────────────────────────────────────────────
  s({ trig = "pu", snippetType = "autosnippet" }, fmta("\\pu{ <> }", { i(1) }), M),
  s({ trig = "cee", snippetType = "autosnippet" }, fmta("\\ce{ <> }", { i(1) }), M),
  s({ trig = "he4", snippetType = "autosnippet" }, { t("{}^{4}_{2}He ") }, M),
  s({ trig = "he3", snippetType = "autosnippet" }, { t("{}^{3}_{2}He ") }, M),
  s({ trig = "iso", snippetType = "autosnippet" }, fmta("{}^{<>}_{<>}<>", { i(1, "4"), i(2, "2"), i(3, "He") }), M),

  -- ── Matrix environments ───────────────────────────────────────────────────
  -- MA: inside $$ / environments → multiline with newlines
  -- nA: inside $  → compact, no newlines
  s({ trig = "pmat", snippetType = "autosnippet" }, fmta("\\begin{pmatrix}\n<>\n\\end{pmatrix}", { i(1) }), M_block),
  s({ trig = "pmat", snippetType = "autosnippet" }, fmta("\\begin{pmatrix}<>\\end{pmatrix}", { i(1) }), M_inl),

  s({ trig = "bmat", snippetType = "autosnippet" }, fmta("\\begin{bmatrix}\n<>\n\\end{bmatrix}", { i(1) }), M_block),
  s({ trig = "bmat", snippetType = "autosnippet" }, fmta("\\begin{bmatrix}<>\\end{bmatrix}", { i(1) }), M_inl),

  s({ trig = "Bmat", snippetType = "autosnippet" }, fmta("\\begin{Bmatrix}\n<>\n\\end{Bmatrix}", { i(1) }), M_block),
  s({ trig = "Bmat", snippetType = "autosnippet" }, fmta("\\begin{Bmatrix}<>\\end{Bmatrix}", { i(1) }), M_inl),

  s({ trig = "vmat", snippetType = "autosnippet" }, fmta("\\begin{vmatrix}\n<>\n\\end{vmatrix}", { i(1) }), M_block),
  s({ trig = "vmat", snippetType = "autosnippet" }, fmta("\\begin{vmatrix}<>\\end{vmatrix}", { i(1) }), M_inl),

  s({ trig = "Vmat", snippetType = "autosnippet" }, fmta("\\begin{Vmatrix}\n<>\n\\end{Vmatrix}", { i(1) }), M_block),
  s({ trig = "Vmat", snippetType = "autosnippet" }, fmta("\\begin{Vmatrix}<>\\end{Vmatrix}", { i(1) }), M_inl),

  s({ trig = "matrix", snippetType = "autosnippet" }, fmta("\\begin{matrix}\n<>\n\\end{matrix}", { i(1) }), M_block),
  s({ trig = "matrix", snippetType = "autosnippet" }, fmta("\\begin{matrix}<>\\end{matrix}", { i(1) }), M_inl),
  s({ trig = "cases", snippetType = "autosnippet" }, fmta("\\begin{cases}\n<>\n\\end{cases}", { i(1) }), M),
  s({ trig = "align", snippetType = "autosnippet" }, fmta("\\begin{align}\n<>\n\\end{align}", { i(1) }), M),
  s({ trig = "array", snippetType = "autosnippet" }, fmta("\\begin{array}\n<>\n\\end{array}", { i(1) }), M),

  -- ── Brackets  (mA) ───────────────────────────────────────────────────────
  s({ trig = "avg", snippetType = "autosnippet" }, fmta("\\langle <> \\rangle <>", { i(1), i(2) }), M),
  s({ trig = "norm", snippetType = "autosnippet", priority = 1001 }, fmta("\\lvert <> \\rvert <>", { i(1), i(2) }), M),
  s({ trig = "Norm", snippetType = "autosnippet", priority = 1001 }, fmta("\\lVert <> \\rVert <>", { i(1), i(2) }), M),
  s({ trig = "ceil", snippetType = "autosnippet" }, fmta("\\lceil <> \\rceil <>", { i(1), i(2) }), M),
  s({ trig = "floor", snippetType = "autosnippet" }, fmta("\\lfloor <> \\rfloor <>", { i(1), i(2) }), M),
  s({ trig = "mod", snippetType = "autosnippet" }, fmta("|<>|<>", { i(1), i(2) }), M),
  -- bracket wrapping (with visual support)
  s({ trig = "(", snippetType = "autosnippet" }, fmta("(<>)<>", { d(1, get_visual), i(2) }), M),
  s({ trig = "[", snippetType = "autosnippet" }, fmta("[<>]<>", { d(1, get_visual), i(2) }), M),
  s({ trig = "{", snippetType = "autosnippet" }, fmta("{<>}<>", { d(1, get_visual), i(2) }), M),
  -- \left…\right… variants
  s({ trig = "lr(", snippetType = "autosnippet" }, fmta("\\left( <> \\right) <>", { i(1), i(2) }), M),
  s({ trig = "lr{", snippetType = "autosnippet" }, fmta("\\left\\{ <> \\right\\} <>", { i(1), i(2) }), M),
  s({ trig = "lr[", snippetType = "autosnippet" }, fmta("\\left[ <> \\right] <>", { i(1), i(2) }), M),
  s({ trig = "lr|", snippetType = "autosnippet" }, fmta("\\left| <> \\right| <>", { i(1), i(2) }), M),
  s({ trig = "lra", snippetType = "autosnippet" }, fmta("\\left<< <> \\right>> <>", { i(1), i(2) }), M),

  -- ── Misc ─────────────────────────────────────────────────────────────────
  s(
    { trig = "box", snippetType = "autosnippet" }, -- MA: block math only
    fmta("\\boxed{<>}", { i(1) }),
    M_block
  ),

  -- tayl  →  Taylor expansion                               mA
  s(
    { trig = "tayl", snippetType = "autosnippet" },
    fmta(
      "<>(<> + <>) = <>(<>) + <>'(<>)<> + <>''(<>) \\frac{<>^{2}}{2!} + \\dots<>",
      { i(1, "f"), i(2, "x"), i(3, "h"), rep(1), rep(2), rep(1), rep(2), rep(3), rep(1), rep(2), rep(3), i(4) }
    ),
    M
  ),

  -- iden\d  →  N×N identity matrix in pmatrix               mA
  s({ trig = "iden(%d)", regTrig = true, snippetType = "autosnippet" }, {
    f(function(_, snip)
      local n = tonumber(snip.captures[1])
      local rows = {}
      for row = 1, n do
        local cols = {}
        for col = 1, n do
          cols[col] = (row == col) and "1" or "0"
        end
        rows[row] = table.concat(cols, " & ")
      end
      return "\\begin{pmatrix}\n" .. table.concat(rows, " \\\\\\\\\n") .. "\n\\end{pmatrix}"
    end),
  }, M),
}

return vim.list_extend(text_snippets, math_snippets)
