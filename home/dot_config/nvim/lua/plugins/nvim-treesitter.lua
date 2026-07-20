return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    keys = {
      {
        "]c",
        mode = { "n" },
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        desc = "Go to treesitter function signature context",
      },
    },
  },
  {
    "MeanderingProgrammer/treesitter-modules.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ---@module 'treesitter-modules'
    ---@type ts.mod.UserConfig
    opts = {
      -- Enable incremental selection expansion
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = "v",
          node_decremental = "V",
        },
      },
    },
  },
}
