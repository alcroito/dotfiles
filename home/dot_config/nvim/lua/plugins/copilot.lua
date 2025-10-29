--local plugin = {
  ---- Copilot
  --"CopilotC-Nvim/CopilotChat.nvim",
  --event = 'VeryLazy',
  --lazy = false,
  --dependencies = {
    --{ "github/copilot.vim" },
    --{ "nvim-lua/plenary.nvim", branch = "master" },
  --},
  ---- Only build on macOS and Linux
  ---- https://github.com/CopilotC-Nvim/CopilotChat.nvim/issues/397
  --build = vim.fn.has("win32_fake") == 1 and "" or "make tiktoken",
  --opts = {},
  --init = function()
    ---- Allow copilot for git commit messages
    --vim.g.copilot_filetypes = { gitcommit = true }
  --end,
  --keys = {
    --{ "<leader>ce", mode = { "n", "x", "o" }, "<cmd>CopilotChatExplain<cr>", desc = "Copilot explain" },
  --},
--}

--return plugin

local plugin = {
  "zbirenbaum/copilot.lua",
  event = 'InsertEnter',
  dependencies = {
    "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
  },
  opts = {
    --panel = {
      --auto_refresh = true,
    --},
    filetypes = {
      terraform = true,
      yaml = true,
      gitcommit = true,
    },
    suggestion = {
      auto_trigger = true,
      debounce = 200,
      keymap = {
        accept = "<Tab>",
      },
    },

    --nes = {
      --enabled = true,
      --auto_trigger = true,
      --keymap = {
          --accept_and_goto = "<leader>p",
          --accept = false,
          --dismiss = "<Esc>",
        --},
    --}
  },
  config = function(func, opts)
    require("copilot").setup(opts)
  end,
}

return plugin
