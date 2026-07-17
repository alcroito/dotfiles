return {
  "echasnovski/mini.nvim",
  version = false,
  event = "VeryLazy",
  config = function()
    --  Mini surround instead of sandwhich
    require("mini.surround").setup({
      mappings = {
        add = "ysa", -- Add surrounding in Normal and Visual modes
        delete = "ysd", -- Delete surrounding
        find = "ysf", -- Find surrounding (to the right)
        find_left = "ysF", -- Find surrounding (to the left)
        highlight = "ysh", -- Highlight surrounding
        replace = "ysr", -- Replace surrounding

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    })

    local spec_treesitter = require("mini.ai").gen_spec.treesitter
    require("mini.ai").setup({
      custom_textobjects = {
        F = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
        c = spec_treesitter({ a = "@class.outer", i = "@class.inner" }),
        o = spec_treesitter({
          a = { "@conditional.outer", "@loop.outer" },
          i = { "@conditional.inner", "@loop.inner" },
        }),
      },
    })

    --require("mini.completion").setup({
    --delay = { completion = 300, info = 100, signature = 50 },
    --})

    -- Mini files, for navigating files
    -- Disabled for now
    -- require('mini.files').setup()
    -- "lua vim.keymap.set("n", "<leader>m", "<cmd>lua MiniFiles.open()<cr>", opts)
  end,
}
