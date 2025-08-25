return {
  --{
    ---- debugger integration
    --"rcarriga/nvim-dap-ui",
    --dependencies = {
      --"mfussenegger/nvim-dap",
      --"nvim-neotest/nvim-nio",
      --"jbyuki/one-small-step-for-vimkind",
    --},
    --keys = {
      --{ "<leader>db", mode = { "n" }, function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
    --},
    --lazy = true,
    --config = function()
      --local dap = require("dap")
      --dap.adapters.lldb = {
        --type = "executable",
        --command = "/opt/homebrew/opt/llvm/bin/lldb-dap",
        --name = "lldb",
      --}
      --dap.configurations.lua = {
        --{
          --type = "nlua",
          --request = "attach",
          --name = "Attach to running Neovim instance",
        --},
      --}
      --dap.configurations.cpp = {
        --{
          --name = "Launch",
          --type = "lldb",
          --request = "launch",
          --program = function()
            --return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          --end,
          --cwd = "${workspaceFolder}",
          --stopOnEntry = false,
          --args = {},
        --},
      --}

      --dap.adapters.nlua = function(callback, config)
        --callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
      --end

      --require("dap-view").setup()

      --vim.keymap.set("n", "<leader>db", require("dap").toggle_breakpoint, { noremap = true })
      --vim.keymap.set("n", "<leader>dc", require("dap").continue, { noremap = true })
      --vim.keymap.set("n", "<leader>do", require("dap").step_over, { noremap = true })
      --vim.keymap.set("n", "<leader>di", require("dap").step_into, { noremap = true })

      --vim.keymap.set("n", "<leader>dl", function()
        --require("osv").launch({ port = 8086, log = true, blocking = true, break_on_exception = true, output = true })
      --end, { noremap = true })

      --vim.keymap.set("n", "<leader>dw", function()
        --local widgets = require("dap.ui.widgets")
        --widgets.hover()
      --end)

      --vim.keymap.set("n", "<leader>df", function()
        --local widgets = require("dap.ui.widgets")
        --widgets.centered_float(widgets.frames)
      --end)
    --end,
  --},
  --{
    --"igorlfs/nvim-dap-view",
    --lazy = true,
    -----@module 'dap-view'
    -----@type dapview.Config
    --opts = {
      --winbar = {
        --show = true,
        --controls = {
          --enabled = true,
        --},
      --},
      --auto_toggle = true,
    --},
  --},
  {
    "miroshQa/debugmaster.nvim",
     -- osv is needed if you want to debug neovim lua code. Also can be used
     -- as a way to quickly test-drive the plugin without configuring debug adapters
    dependencies = { "mfussenegger/nvim-dap", "jbyuki/one-small-step-for-vimkind", },
    config = function()
      local dm = require("debugmaster")
      -- make sure you don't have any other keymaps that starts with "<leader>d" to avoid delay
      -- Alternative keybindings to "<leader>d" could be: "<leader>m", "<leader>;"
      vim.keymap.set({ "n", "v" }, "<leader>d", dm.mode.toggle, { nowait = true })
      -- If you want to disable debug mode in addition to leader+d using the Escape key:
       --vim.keymap.set("n", "<Esc>", dm.mode.disable)
      -- This might be unwanted if you already use Esc for ":noh"
      vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

      dm.plugins.osv_integration.enabled = true -- needed if you want to debug neovim lua code
      local dap = require("dap")
      -- Configure your debug adapters here
      -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

      dap.adapters.lldb = {
        type = "executable",
        command = "/opt/homebrew/opt/llvm/bin/lldb-dap",
        name = "lldb",
      }
      dap.configurations.lua = {
        {
          type = "nlua",
          request = "attach",
          name = "Attach to running Neovim instance",
        },
      }
      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }

      dap.adapters.nlua = function(callback, config)
        callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
      end
    end
  },
}
