return {
  -- vim keybindings popup guide
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    win = {
      width = 70,
    },
    preset = "helix",
    triggers = {
      { "<auto>", mode = "nixsotc" },
      { "a", mode = { "n", "v" } },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
