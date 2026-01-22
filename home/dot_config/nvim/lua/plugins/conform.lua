return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      cpp = { "clang_format" },
      go = { "gofmt" },
      javascript = { "prettier" },
      lua = { "stylua" },
      python = { "ruff" },
      rust = { "rustfmt" },
      terraform = { "hcl" },
      toml = { "tombi" },
      typescript = { "prettier" },
      yaml = { "yamlfmt" },
    },
  },
}
