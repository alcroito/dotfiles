local plugin = {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  dependencies = {
    "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
  },
  opts = {
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
  },
  config = function(func, opts)
    require("copilot").setup(opts)
  end,
}

return plugin
