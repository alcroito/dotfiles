return {
  -- Magit git like experience
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",         -- required
    "dlyongemallo/diffview-plus.nvim", -- optional - Diff integration
    "m00qek/baleia.nvim",            -- optional - renders the ANSI colors emitted by the log_pager
  },
  opts = {
    -- Headers are omitted so delta's output stays line-for-line with the hunk neogit parsed,
    -- otherwise line-wise staging targets the wrong lines.
    log_pager = { "delta", "--width", "117", "--file-style=omit", "--hunk-header-style=omit" },
    -- Context highlighting repaints the hunk under the cursor and wipes out delta's colors
    disable_context_highlighting = true,
    integrations = {
      snacks = true,
    },
  },
  config = function(_, opts)
    vim.g.baleia = require("baleia").setup {}
    require("neogit").setup(opts)
  end,
  keys = {
    { "<leader>ng", "<cmd>Neogit<CR>", desc = "NeoGit" },
  },
}
