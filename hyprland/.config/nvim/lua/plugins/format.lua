return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = { "dotnet_format" },
        python = { "isort", "black" },
      },
    },
  },
}
