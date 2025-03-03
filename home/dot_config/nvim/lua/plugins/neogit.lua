return {
  -- Magit git like experience
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",         -- required
    "sindrets/diffview.nvim",        -- optional - Diff integration
  },
  config = true,
  keys = {
    { "<leader>ng", "<cmd>Neogit<CR>", desc = "NeoGit" },
  },
}
