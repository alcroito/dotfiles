-- Optionally load local configuration if it exists
pcall(require, "config.local_machine")

require("config.lazy")

vim.api.nvim_create_user_command('ClangdCompileCommands', function(opts)
  local path_arg = opts.args

  -- Default to current working directory if no argument is provided
  if path_arg == "" then
    path_arg = vim.fn.getcwd()
  end

  -- Expand special path characters like ~ (tilde) and environment variables
  local expanded_path = vim.fn.expand(path_arg)

  -- 1. Stop the current clangd server
  vim.cmd("LspStop clangd")

  -- 2. Reconfigure clangd using the new vim.lsp.config API
  -- This replaces the deprecated require('lspconfig').setup({})
  vim.lsp.config('clangd', {
    cmd = { "clangd", "--compile-commands-dir=" .. expanded_path },
    -- If you have other configurations (like capabilities, on_attach, etc.),
    -- ensure they are included here or merged appropriately, as this defines
    -- the server configuration for the subsequent start.
  })

  -- 3. Start the server with the new configuration
  vim.cmd("LspStart clangd")

  print("Clangd restarted with compile_commands dir: " .. expanded_path)
end, {
  nargs = '?',
  complete = 'dir'
})

