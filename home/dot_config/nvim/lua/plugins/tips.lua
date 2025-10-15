return {
  "saxon1964/neovim-tips",
  version = "*", -- Only update on tagged releases
  dependencies = {
    "MunifTanjim/nui.nvim",
    "MeanderingProgrammer/render-markdown.nvim"
  },
  opts = {
    -- OPTIONAL: Daily tip mode (default: 1)
    -- 0 = off, 1 = once per day, 2 = every startup
    daily_tip = 0,
  },
  keys = {
    {"<leader>nto", "<cmd>NeovimTips<CR>", desc = "Neovim tips", },
  },
  --init = function()
    ---- OPTIONAL: Change to your liking or drop completely
    ---- The plugin does not provide default key mappings, only commands
    --local map = vim.keymap.set
    --map("n", "<leader>nto", ":NeovimTips<CR>", { desc = "Neovim tips", noremap = true, silent = true })
    --map("n", "<leader>nte", ":NeovimTipsEdit<CR>", { desc = "Edit your Neovim tips", noremap = true, silent = true })
    --map("n", "<leader>nta", ":NeovimTipsAdd<CR>", { desc = "Add your Neovim tip", noremap = true, silent = true })
    --map("n", "<leader>nth", ":help neovim-tips<CR>", { desc = "Neovim tips help", noremap = true, silent = true })
    --map("n", "<leader>ntr", ":NeovimTipsRandom<CR>", { desc = "Show random tip", noremap = true, silent = true })
    --map("n", "<leader>ntp", ":NeovimTipsPdf<CR>", { desc = "Open Neovim tips PDF", noremap = true, silent = true })
  --end
}
