local plugin = {
  -- Copilot
  "CopilotC-Nvim/CopilotChat.nvim",
  event = 'VeryLazy',
  lazy = false,
  dependencies = {
    { "github/copilot.vim" },
    { "nvim-lua/plenary.nvim", branch = "master" },
  },
  -- Only build on macOS and Linux
  -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/issues/397
  build = vim.fn.has("win32_fake") == 1 and "" or "make tiktoken",
  opts = {},
  init = function()
    -- Allow copilot for git commit messages
    vim.g.copilot_filetypes = { gitcommit = true }
  end,
  keys = {
    { "<leader>ce", mode = { "n", "x", "o" }, "<cmd>CopilotChatExplain<cr>", desc = "Copilot explain" },
  },
}

return plugin
