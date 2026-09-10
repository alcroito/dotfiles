return {
  "dlyongemallo/diffview-plus.nvim",
  opts = {
    view = {
      merge_tool = {
        layout = "diff4_mixed",
      },
    },
  },
  keys = {
    { "<leader>mt", mode = { "n", "x", "o" }, "<cmd>DiffviewOpen<CR>", desc = "Git Mergetool DiffView" },
    {
      "<leader>dv",
      mode = { "n", "x", "o" },
      "<cmd>DiffviewOpen HEAD^! --imply-local<CR>",
      desc = "Git DiffView last",
    },
    { "<leader>dh", mode = { "n", "x", "o" }, "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
    { "<leader>dH", mode = { "n", "x", "o" }, "<cmd>DiffviewFileHistory<cr>", desc = "File history (repo)" },
  },
}
