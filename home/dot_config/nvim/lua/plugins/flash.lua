return {
  -- Like easy motion
  "folke/flash.nvim",
  --event = "VeryLazy",
  -- Enables regular search jump labels and f,t motions
  ---@type Flash.Config
  opts = { modes = {search = {enabled = false}}},
  -- stylua: ignore
  -- Bindings for easymotion flash movement
  keys = {
    { "<leader>w", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
  },
}
