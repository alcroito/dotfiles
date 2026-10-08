return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    { "kevinhwang91/promise-async" },
  },
  init = function()
    vim.o.foldcolumn = "1" -- '0' is not bad
    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
  end,
  event = "BufReadPost",
  -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
  keys = {
    {
      "zR",
      function()
        require("ufo").openAllFolds()
      end,
      desc = "Open all folds",
    },
    {
      "zM",
      function()
        require("ufo").closeAllFolds()
      end,
      desc = "Close all folds",
    },
  },
  config = function()
    -- Option 3: treesitter as a main provider instead
    -- (Note: the `nvim-treesitter` plugin is *not* needed.)
    -- ufo uses the same query files for folding (queries/<lang>/folds.scm)
    -- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
    require("ufo").setup({
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    })
  end,
}
