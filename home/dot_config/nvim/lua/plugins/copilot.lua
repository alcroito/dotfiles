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
    end
  end,
}

return plugin
