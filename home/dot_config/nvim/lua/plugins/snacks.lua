return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      matcher = {
        cwd_bonus = true,
        frecency = false,
      },
      projects = {
        "~/.config/nvim",
      },
      win = {
        input = {
          -- stylua: ignore
          keys = {
            ["<a-Up>"] = { "history_forward", mode = { "i", "n" } },
            ["<a-Down>"] = { "history_back", mode = { "i", "n" } },
            ["<PageUp>"] = { "list_scroll_up", mode = { "i", "n" } },
            ["<PageDown>"] = { "list_scroll_down", mode = { "i", "n" } },
            ["<a-c>"] = { "toggle_cwd", mode = { "i", "n" } },
            ['<M-/>'] = { 'choose_history', mode = { 'i', 'n' } },
            ["<a-a>"] = { "sidekick_send", mode = { "n", "i" }, },
          },
        },
      },
      actions = {
        sidekick_send = function(...)
          return require("sidekick.cli.picker.snacks").send(...)
        end,
        ---@param picker snacks.Picker
        choose_history = function(picker)
          local history = picker.history.kv.data
          local items = {}
          for i = 1, #history do
            local hist = history[#history + 1 - i]
            table.insert(items, {
              idx = i,
              pattern = hist.pattern,
              search = hist.search,
              live = hist.live,
              text = hist.search .. " " .. hist.pattern,
            })
          end
          Snacks.picker.pick({
            title = "Picker history",
            items = items,
            main = { current = true }, -- NOTE: Prevent closing the parent picker
            layout = { preset = "select" },
            supports_live = false,
            transform = function(item)
              return not (item.search == "" and item.search == "")
            end,
            format = function(item)
              local ico = { live = picker.opts.icons.ui.live, prompt = picker.opts.prompt }
              local part1 = item.live and item.pattern or item.search
              local part2 = item.live and item.search or item.pattern
              --
              local text = {}
              table.insert(text, { item.live and ico.live or "  ", "Special" })
              table.insert(text, { " " })
              table.insert(text, { part1, "SnacksPickerInputSearch" })
              if part1 ~= "" and part2 ~= "" then
                table.insert(text, { " " })
                table.insert(text, { ico.prompt, "SnacksPickerPrompt" })
              end
              table.insert(text, { part2 })
              return text
            end,
            confirm = function(history_picker, item)
              local mode = vim.fn.mode()
              picker.opts.live = item.live
              picker.input:set(item.pattern, item.search)
              history_picker:close()
              if mode == "i" then
                -- stylua: ignore
                vim.schedule(function() vim.cmd 'startinsert!' end)
              end
            end,
          })
        end,
        ---@param p snacks.Picker
        toggle_cwd = function(p)
          --local root = LazyVim.root({ buf = p.input.filter.current_buf, normalize = true })
          --local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
          local buf_name = vim.api.nvim_buf_get_name(p.input.filter.current_buf)
          local cwd = vim.fn.fnamemodify(buf_name, ":p:h")
          local current = p:cwd()
          local root = vim.fn.getcwd()
          p:set_cwd(current == root and cwd or root)
          p:find()
        end,
      },
      previewers = {
        file = {
          max_size = 1024 * 1024 * 50, -- 100 MB
        },
      },
    },
    explorer = {
      replace_netrw = false,
    },
    lazygit = {
      config = {},
    },
    dashboard = {
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git status --short --branch --renames",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
        { section = "startup" },
      },
    },
  },
  -- stylua: ignore
  keys = {
    -- Mine
    { "<leader>sa", function() Snacks.picker() end, desc = "All pickers" },
    { "<leader>ss", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fts", function() Snacks.picker.treesitter() end, desc = "Find tree sitter symbols" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>fc", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    { "<leader>r", function() Snacks.picker.recent() end, desc = "Recent" },
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>;", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep (Root Dir)" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Undotree" },
    { "<leader><space>", function() Snacks.picker.files() end, desc = "Find Files (Root Dir)" },


    { "<leader>fast", function()
      Snacks.picker.pick {
        format = 'file',
        show_empty = true,
        live = true,
        supports_live = true,
        finder = function(opts, ctx)
          local run = { 'ast-grep', 'run', '--context=0', '--json=stream' }
          if vim.fn.has 'win32' == 1 then
            run[1] = 'sg'
          end
          local pattern, pargs = Snacks.picker.util.parse(ctx.filter.search)
          vim.list_extend(run, pargs)
          table.insert(run, string.format('--pattern=%s', pattern))
          return require('snacks.picker.source.proc').proc({
            opts,
            {
              notify = false,
              cmd = run[1],
              args = vim.list_slice(run, 2),
              transform = function(item)
                local entry = vim.json.decode(item.text)
                if vim.tbl_isempty(entry) then
                  return false
                else
                  local start = entry.range.start
                  item.file = entry.file
                  item.line = entry.text
                  item.pos = { tonumber(start.line) + 1, tonumber(start.column) }
                end
              end,
            },
          }, ctx)
        end,
      }
    end, desc = "Find ast-grep" },
    --
    -- Top Pickers & Explorer
    --{ "<leader>sm", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    --{ "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    --{ "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    --{ "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    --{ "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    --{ "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
    -- find
    --{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    --{ "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    --{ "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    --{ "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    --{ "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
    --{ "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
    -- git
    --{ "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    --{ "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    --{ "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
    --{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    --{ "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
    --{ "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
    --{ "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
    -- Grep
    --{ "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    --{ "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    --{ "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    --{ "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    -- search
    --{ '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
    --{ '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
    --{ "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
    --{ "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    --{ "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
    --{ "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
    --{ "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    --{ "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    --{ "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    --{ "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
    --{ "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
    --{ "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    --{ "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    --{ "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
    --{ "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
    --{ "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
    --{ "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
    --{ "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    --{ "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    --{ "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
    --{ "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    -- LSP
    --{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    --{ "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
    --{ "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    --{ "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    --{ "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    --{ "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    --{ "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
  },
}
