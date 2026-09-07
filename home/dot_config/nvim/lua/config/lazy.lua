-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Tested against the module entry point, not the directory: an interrupted clone
-- leaves a lazypath holding only .git, which a directory test accepts forever.
if not (vim.uv or vim.loop).fs_stat(lazypath .. "/lua/lazy/init.lua") then
  vim.fn.delete(lazypath, "rf")
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    -- Only wait for a key when someone is there to press one. Under
    -- `nvim --headless` in the install scripts there is no ui and stdin is the
    -- installer's exhausted pipe, so getchar() would block the bootstrap
    -- forever rather than let it fail.
    if #vim.api.nvim_list_uis() > 0 then
      vim.api.nvim_echo({ { "\nPress any key to exit..." } }, true, {})
      vim.fn.getchar()
    end
    os.exit(1)
  end
end
vim.opt.rtp:append(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  checker = { enabled = false },
  performance = {
    rtp = {
      reset = false,
    },
  },
})

-- Enable virtual inline diagnostics
vim.diagnostic.config({
  virtual_text = true
})
