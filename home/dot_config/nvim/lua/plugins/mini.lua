return {
  'echasnovski/mini.nvim',
  version = false,
  event = 'VeryLazy',
  config = function()
    --  Mini surround instead of sandwhich
    require('mini.surround').setup()

    -- Mini files, for navigating files
    -- Disabled for now
    -- require('mini.files').setup()
    -- "lua vim.keymap.set("n", "<leader>m", "<cmd>lua MiniFiles.open()<cr>", opts)
  end,
}
