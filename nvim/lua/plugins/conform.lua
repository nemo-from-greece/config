-- lua/plugins/conform.lua
-- Drop this file at: ~/.config/nvim/lua/plugins/conform.lua
--
-- Handles format-on-save for all filetypes.
-- Formatters are sourced from Mason's bin directory automatically.
--
-- To install formatters via Mason:
--   :MasonInstall tex-fmt bibtex-tidy ruff
--
-- To manually trigger formatting:
--   <leader>f   format current buffer
--   <leader>F   format current selection (visual mode)

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" }, -- load just before a save, keeps startup fast
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "n",
      desc = "Format buffer",
    },
    {
      "<leader>F",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "v",
      desc = "Format selection",
    },
  },
  opts = {
    -- ── Formatter assignments per filetype ──────────────────────────────────
    formatters_by_ft = {
      tex = { "tex-fmt" },
      bib = { "bibtex-tidy" },
      python = { "ruff_format" }, -- ruff's formatter (replaces black)

      -- Add others here as needed, e.g.:
      -- lua      = { "stylua" },
      -- json     = { "prettier" },
      -- markdown = { "prettier" },
    },

    -- ── Format on save ───────────────────────────────────────────────────────
    format_on_save = {
      timeout_ms = 2000, -- give slow formatters (bibtex-tidy) time to run
      lsp_fallback = true, -- fall back to LSP formatting if no formatter listed
    },

    -- ── Formatter-specific options ───────────────────────────────────────────
    formatters = {
      ["tex-fmt"] = {
        -- tex-fmt defaults are sensible; uncomment to override:
        -- args = { "--stdin", "--wrap", "80" },
      },
      ["bibtex-tidy"] = {
        -- Sort entries alphabetically by key, align values, remove duplicates.
        -- Full option list: https://github.com/FlamingTempura/bibtex-tidy
        args = {
          "--align=14",
          "--sort=key",
          "--duplicates=key",
          "--no-escape",
          "--strip-enclosing-braces",
          "--drop-all-caps",
          "--trailing-commas",
          "--stdin",
        },
      },
    },
  },
}
