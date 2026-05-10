-- lua/plugins/luasnip.lua
-- Drop this file at: ~/.config/nvim/lua/plugins/luasnip.lua
--
-- Snippet keybindings:
--   <Tab>    - expand snippet OR jump to next tabstop
--   <S-Tab>  - jump to previous tabstop
--   <C-l>    - cycle through choice nodes
--   <leader>rs  - reload snippets without restarting nvim (handy while editing tex.lua)
--
-- Completion menu keybindings:
--   <C-n> / <C-p>    - navigate completion items
--   <CR>             - confirm selection
--   <C-Space>        - force open completion menu
--   <C-e>            - close completion menu

return {
  -- ── LuaSnip ────────────────────────────────────────────────────────────────
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    -- jsregexp enables regex-captures in snippets (needed for the
    -- auto-subscript and fraction-from-token snippets in tex.lua)
    build = "make install_jsregexp",
    event = "InsertEnter",
    config = function()
      local ls = require("luasnip")

      ls.config.set_config({
        history = true, -- jump back into exited snippets
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true, -- REQUIRED for all the math autosnippets
        -- Visual indicator for choice nodes
        ext_opts = {
          [require("luasnip.util.types").choiceNode] = {
            active = { virt_text = { { "●", "DiagnosticWarn" } } },
          },
        },
      })

      -- Load all .lua snippet files from ~/.config/nvim/snippets/
      -- Filename = filetype, so snippets/tex.lua → applies to .tex files
      require("luasnip.loaders.from_lua").load({
        paths = vim.fn.stdpath("config") .. "/snippets",
      })

      -- ── Keymaps ──────────────────────────────────────────────────────────────
      -- Tab: expand snippet if at a trigger, otherwise jump forward
      vim.keymap.set({ "i", "s" }, "<Tab>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
        end
      end, { silent = true, desc = "LuaSnip expand / jump forward" })

      -- S-Tab: jump backward through tabstops
      vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true, desc = "LuaSnip jump backward" })

      -- C-l: cycle choice node options
      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true, desc = "LuaSnip next choice" })

      -- <leader>rs: hot-reload snippets without restarting nvim
      vim.keymap.set("n", "<leader>rs", function()
        require("luasnip.loaders.from_lua").load({
          paths = vim.fn.stdpath("config") .. "/snippets",
        })
        vim.notify("Snippets reloaded!", vim.log.levels.INFO)
      end, { desc = "Reload LuaSnip snippets" })
    end,
  },

  -- ── nvim-cmp (completion engine) ───────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "saadparwaiz1/cmp_luasnip", -- snippet completions
      "hrsh7th/cmp-nvim-lsp", -- LSP completions
      "hrsh7th/cmp-buffer", -- completions from current buffer
      "hrsh7th/cmp-path", -- file path completions
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          -- select=false: only confirm if you explicitly highlighted an item
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),

        sources = cmp.config.sources({
          { name = "luasnip", priority = 10 },
          { name = "nvim_lsp", priority = 8 },
          { name = "buffer", priority = 5 },
          { name = "path", priority = 3 },
        }),

        -- Don't show completion menu inside comments or strings in tex
        -- (optional – remove if you want completions everywhere)
        enabled = function()
          local ctx = require("cmp.config.context")
          if vim.bo.filetype == "tex" then
            -- still show inside math zones and commands
            return true
          end
          return not ctx.in_treesitter_capture("comment") and not ctx.in_syntax_group("Comment")
        end,
      })
    end,
  },
}
