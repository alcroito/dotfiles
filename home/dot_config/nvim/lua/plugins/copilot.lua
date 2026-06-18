-- Detect hostname and check against whitelist
local function get_hostname()
  local handle = io.popen("hostname")
  if not handle then
    return nil
  end
  local hostname = handle:read("*a")
  handle:close()
  if hostname then
    -- Trim whitespace and convert to lowercase for comparison
    hostname = hostname:gsub("%s+", ""):lower()
  end
  return hostname
end

local function is_hostname_allowed()
  local allowed_hostnames = {
    "coco",
  }

  local current_hostname = get_hostname()
  if not current_hostname then
    return false -- Default to disabled if hostname detection fails
  end

  for _, allowed in ipairs(allowed_hostnames) do
    if current_hostname:find(allowed:lower(), 1, true) then
      return true
    end
  end

  return false
end

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
    -- only setup if global state control value is set ( and it's not by default )
    -- Set global copilot enabled state based on hostname if not already set
    if vim.g.copilot_enabled == nil then
      vim.g.copilot_enabled = is_hostname_allowed()
    end
    local is_off = vim.g.copilot_enabled
    if not is_off then
      -- setup own false augroup to prevent inbuilt teardown from erroring out due to lack
      -- of internally set up augroup
      vim.api.nvim_create_augroup("copilot.client", { clear = true })
      -- wrap things down forcefully using inbuilt client function
      require("copilot.client").teardown()
    else
      require("copilot").setup(opts)

      -- Workaround for quicker.nvim#72 (colocated with the copilot config since it
      -- only matters when copilot is actually running). copilot races on a
      -- scheduled BufEnter and attaches its LSP client to a buffer that only
      -- becomes the quickfix buffer a tick later (e.g. snacks.nvim picker ->
      -- quickfix), so its should_attach buftype guard is bypassed. Once attached,
      -- editing/rewriting the quickfix buffer drives Neovim's incremental sync
      -- into the compute_start_range / compute_end_range assertions in
      -- vim/lsp/sync.lua.
      --
      -- An LSP has no business on a quickfix buffer, so detach any client that
      -- ends up on one. Two hooks are needed:
      --   * LspAttach: catches clients attaching while the buffer is already special.
      --   * FileType qf: catches the race where copilot attached earlier (while the
      --     buffer still had buftype="") and the buffer only became a quickfix
      --     buffer afterwards -- LspAttach won't fire again for it.
      local function detach_lsp_from_special_buf(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
          pcall(vim.lsp.buf_detach_client, bufnr, client.id)
        end
      end

      local aug = vim.api.nvim_create_augroup("copilot_qf_detach", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = aug,
        desc = "Detach LSP clients from non-file buffers -- quicker.nvim#72",
        callback = function(args)
          local bt = vim.bo[args.buf].buftype
          if bt ~= "" and bt ~= "help" then
            vim.schedule(function()
              detach_lsp_from_special_buf(args.buf)
            end)
          end
        end,
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        group = aug,
        desc = "Detach LSP clients from quickfix buffers -- quicker.nvim#72",
        callback = function(args)
          vim.schedule(function()
            detach_lsp_from_special_buf(args.buf)
          end)
        end,
      })
    end
  end,
}

return plugin
