return {
  "esmuellert/codediff.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = "CodeDiff",
  config = function()
    require("codediff").setup({})
  end,
  keys = {
    {"<leader>vd", "<cmd>:CodeDiff<cr>", desc = "VS Code Diff"},
  },
}
