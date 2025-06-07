if true then return {} end

return {
  -- Use yazi as terminal file manager
  "rolv-apneseth/tfm.nvim",
  -- So that we replace netrw
  lazy = false,
  opts = {
    replace_netrw = true,
  },
  keys = {
    {"<leader>e", function() require('tfm').open() end, desc = "Yazi", },
  },
}
