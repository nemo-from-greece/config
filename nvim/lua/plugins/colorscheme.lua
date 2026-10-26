return {
  "folke/tokyonight.nvim",
  opts = {
    style = "moon",
    on_colors = function(colors)
      colors.bg = "#101923"
      colors.bg_highlight = "#182535"
      colors.bg_dark = "#0c131a"
    end,
  },
}
