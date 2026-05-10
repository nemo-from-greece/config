return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ltex_plus = {
        settings = {
          ltex = {
            checkFrequency = "save",
          },
        },
      },
    },
  },
}
