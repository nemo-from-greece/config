-- lua/plugins/vimtex.lua
-- Drop this file at: ~/.config/nvim/lua/plugins/vimtex.lua
--
-- Prerequisites (run these once in your terminal):
--   sudo pacman -S texlive texlive-latexextra texlive-science texlive-pictures texlive-bibtexextra
--   sudo pacman -S zathura zathura-pdf-mupdf
--
-- Key VimTeX bindings (leader = '\ ' by default):
--   \ll  - start/stop compilation (continuous)
--   \lv  - forward search (jump to position in PDF)
--   \le  - open error log in quickfix
--   \lc  - clean auxiliary files
--   \lt  - open table of contents
--   \lm  - show LaTeX math errors
--   \li  - show info about current document
--   \ls  - toggle compilation status
--   Ctrl+] - jump to definition of \label/\cite under cursor

return {
  "lervag/vimtex",
  -- Load when opening a .tex file (not at startup, saves memory)
  ft = { "tex", "bib" },
  init = function()
    -- ── PDF viewer ────────────────────────────────────────────────────────────
    vim.g.vimtex_view_method = "zathura"

    -- ── Compiler ──────────────────────────────────────────────────────────────
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
      aux_dir = ".aux", -- keep your project root clean
      out_dir = ".out", -- compiled PDF goes here
      callback = 1,
      continuous = 1, -- recompile on save
      executable = "latexmk",
      options = {
        "-verbose",
        "-file-line-error",
        "-synctex=1", -- enables forward/inverse search with Zathura
        "-interaction=nonstopmode",
        "-shell-escape", -- needed for minted, tikz-externalize, etc.
      },
    }
    -- ── Quickfix filtering ────────────────────────────────────────────────────
    vim.g.vimtex_quickfix_ignore_filters = {
      "Underfull \\\\hbox",
      "Overfull \\\\hbox",
      -- "LaTeX Warning: .\\+float specifier changed to",
      -- "Package hyperref Warning",
      -- "Package caption Warning",
    }

    -- ── Quickfix window ───────────────────────────────────────────────────────
    -- 0 = never open, 1 = always open, 2 = open only on errors/warnings
    vim.g.vimtex_quickfix_mode = 2
    vim.g.vimtex_quickfix_open_on_warning = 0 -- don't open for warnings alone

    -- ── Conceal ───────────────────────────────────────────────────────────────
    -- Makes math look cleaner in the editor (renders \alpha as α, etc.)
    vim.opt.conceallevel = 1
    vim.g.vimtex_syntax_conceal_disable = 0

    -- ── Insert-mode mappings ──────────────────────────────────────────────────
    -- Disable vimtex's built-in insert-mode maps; we use LuaSnip instead
    vim.g.vimtex_imaps_enabled = 0

    -- ── Misc ──────────────────────────────────────────────────────────────────
    -- Tell vim this is always LaTeX, never plain TeX or ConTeXt
    vim.g.tex_flavor = "latex"

    -- Fold by sections/environments (optional, disable if too slow)
    vim.g.vimtex_fold_enabled = 1

    -- TOC settings
    vim.g.vimtex_toc_config = {
      name = "TOC",
      layers = { "content", "todo", "include" },
      split_width = 30,
      todo_sorted = 0,
      show_help = 1,
      show_numbers = 1,
    }
  end,
}
