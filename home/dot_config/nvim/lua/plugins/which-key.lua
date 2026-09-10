return {
  -- vim keybindings popup guide
  "folke/which-key.nvim",
  event = "VeryLazy",
  filter = function(mapping)
    return mapping.desc ~= "diffview_ignore"
  end,
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
