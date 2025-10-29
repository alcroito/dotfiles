local function lsp_status()
  local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
  if #attached_clients == 0 then
    return ""
  end
  local names = {}
  for _, client in ipairs(attached_clients) do
    local name = client.name:gsub("language.server", "ls")
    table.insert(names, name)
  end
  return "LSP: " .. table.concat(names, ", ")
end

local function macro()
  local reg = vim.fn.reg_recording()
  if reg == "" then
    return ""
  end
  return "Recording macro in: " .. reg
end

local function line_total()
  return vim.api.nvim_buf_line_count(vim.fn.winbufnr(vim.g.statusline_winid))
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local dmode_enabled = false
    vim.api.nvim_create_autocmd("User", {
      pattern = "DebugModeChanged",
      callback = function(args)
        dmode_enabled = args.data.enabled
      end,
    })

    local sidekick = {
      function()
        return " "
      end,
      color = function()
        local status = require("sidekick.status").get()
        if status then
          return status.kind == "Error" and "DiagnosticError" or status.busy and "DiagnosticWarn" or "Special"
        end
      end,
      cond = function()
        local status = require("sidekick.status")
        return status.get() ~= nil
      end,
    }

    local sidekick_cli_status = {
      function()
        local status = require("sidekick.status").cli()
        return " " .. (#status > 1 and #status or "")
      end,
      cond = function()
        return #require("sidekick.status").cli() > 0
      end,
      color = function()
        return "Special"
      end,
    }

    require("lualine").setup({
      options = {
        globalstatus = true,
      },
      sections = {
        lualine_a = {
          {
            "mode",
            fmt = function(str)
              return dmode_enabled and "DEBUG" or str
            end,
            color = function(tb)
              return dmode_enabled and "dCursor" or tb
            end,
          },
        },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          { "filename", path = 1 },
          { "branch" },
          { "diff" },
          { "diagnostics" },
          { macro },
        },
        lualine_x = { "lsp_status", "encoding", "fileformat", "filetype", sidekick, sidekick_cli_status },
        lualine_y = { "progress" },
        lualine_z = { "selectioncount", "location", line_total },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { "fzf", "lazy", "mason", "nerdtree" },
    })
  end,
}
