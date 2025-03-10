return {
  -- Use yazi as terminal file manager
  "rolv-apneseth/tfm.nvim",
  config = true,
  opts = {
    replace_netrw = true,
  },
  keys = {
    {"<leader>e", function() require('tfm').open() end, desc = "Yazi", },
  },
}
