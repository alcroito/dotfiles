return {
  "sindrets/diffview.nvim",
  opts = {
    view = {
      merge_tool = {
        layout = "diff4_mixed",
      },
    },
  },
  keys = {
    { "<leader>mt", mode = { "n", "x", "o" }, "<cmd>DiffviewOpen<CR>", desc = "Git Mergetool DiffView" },
  },
}
