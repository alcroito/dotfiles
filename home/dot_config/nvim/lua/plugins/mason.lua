return {
  -- Not lazy: mason.setup() puts mason's bin dir on PATH, which conform's formatters also rely on.
  { "mason-org/mason.nvim", lazy = false, opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {},
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      -- neocmakelsp is not installed via mason, so automatic_enable does not cover it.
      vim.lsp.enable("neocmake")
    end,
  },
}
