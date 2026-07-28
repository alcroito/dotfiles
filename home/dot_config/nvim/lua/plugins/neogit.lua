return {
  -- Magit git like experience
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",         -- required
    "dlyongemallo/diffview-plus.nvim", -- optional - Diff integration
  },
  config = true,
  integrations = {
    snacks = true,
  },
  keys = {
    { "<leader>ng", "<cmd>Neogit<CR>", desc = "NeoGit" },
  },
}
