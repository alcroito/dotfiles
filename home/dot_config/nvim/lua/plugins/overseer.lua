return {
  "stevearc/overseer.nvim",
  ---@module 'overseer'
  ---@type overseer.SetupOpts
  opts = {
    -- dap.lua enables the integration once nvim-dap loads, so overseer does not force it at startup.
    dap = false,
  },
}
