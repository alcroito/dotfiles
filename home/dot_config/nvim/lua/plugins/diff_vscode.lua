return {
  "esmuellert/vscode-diff.nvim",
  branch = "next",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = "CodeDiff",
  config = function()
    require("vscode-diff").setup({})
  end,
  keys = {
    {"<leader>vd", "<cmd>:execute CodeDiff<cr>", desc = "VS Code Diff"},
  },
}
