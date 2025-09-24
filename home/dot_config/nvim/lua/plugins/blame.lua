return {
  "FabijanZulj/blame.nvim",
  opts = {
    mappings = {
        commit_info = "i",
        stack_push = ",",
        stack_pop = ".",
        show_commit = "<CR>",
        close = { "<esc>", "q" },
    },
  },
  keys = {
    { "<leader>b", mode = { "n", "x", "o" }, "<cmd>BlameToggle<CR>", desc = "Git blame" },
  },
}
