return {
  "alcroito/blame.nvim",
  lazy = false,
  config = function()
    require('blame').setup {}
  end,
  keys = {
    { "<leader>b", mode = { "n", "x", "o" }, "<cmd>BlameToggle<CR>", desc = "Git blame" },
  },
}
