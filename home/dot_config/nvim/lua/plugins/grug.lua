return
{
    'MagicDuck/grug-far.nvim',
    -- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
    -- additional lazy config to defer loading is not really needed...
    config = function()
      -- optional setup call to override plugin options
      -- alternatively you can set options with vim.g.grug_far = { ... }
      require('grug-far').setup({
        -- options, see Configuration section below
        -- there are no required options atm
        minSearchChars = 1,
        engines = {
          ripgrep = {
            extraArgs = "-C2",
          },
        }
      });
    end,
    keys = {
      {"<leader>sra", mode = { "n", "x" }, function() require("grug-far").open({prefills = {search = vim.fn.expand("<cword>")}}) end, desc = "Search and replace in current dir", },
      {"<leader>srw", mode = { "n", "x" }, function() require("grug-far").open({visualSelectionUsage = 'operate-within-range'}) end, desc = "Search and replace within", },
      {"<leader>src", mode = { "n", "x" }, function() require("grug-far").open({ prefills = { paths = vim.fn.expand("%"), search = vim.fn.expand("<cword>") } }) end, desc = "Search and replace current file", },
    },
  }
