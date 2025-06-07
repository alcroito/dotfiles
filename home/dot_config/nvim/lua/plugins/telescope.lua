if true then return {} end

local plugin = {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-live-grep-args.nvim",
    -- Show recently open files
    "smartpde/telescope-recent-files",
    -- Per picker-type search / prompt (but not picker) history
    "cosminadrianpopescu/telescope-json-history.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      enabled = function() return vim.fn.executable("cmake") and vim.fn.executable("ninja") end,
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    },
    -- Install treesitter for telescope
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate"
    },
  },
  config = function()
    local telescope = require("telescope")

    -- Telescope remember picker searches per picker type
    telescope.setup{defaults = {
      history = {
        include_cwd = false,
        path = os.getenv('HOME') .. '/.cache/nvim/telescope_history'
      },
      cache_picker = {
        num_pickers = 10
      },
      mappings = {
        i={
          ["<C-n>"] = require('telescope.actions').cycle_history_next,
          ["<C-p>"] = require('telescope.actions').cycle_history_prev
        }
      }
    }}
    --telescope.load_extension("json_history")
    -- Load support specifying live grep args
    --telescope.load_extension("live_grep_args")
    -- Load telescope recent files and set binding
    --telescope.load_extension("recent_files")
    -- Telescope fzf c faster impl
    --if vim.fn.executable("cmake") and vim.fn.executable("ninja") then
      --telescope.load_extension("fzf")
    --end
  end,
  keys = {
    --" Find files using Telescope command-line sugar.
    --{"<leader>ff", function() require("telescope.builtin").find_files() end, desc = "files",},
    --{"<leader>fg", function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "live grep args", },
    {"<leader>fs", "<cmd>:execute 'Telescope live_grep_args default_text=' . expand('<cword>')<cr>", desc = "grep current word"},
    --{"<leader>fb", function() require("telescope.builtin").buffers() end, desc = "buffers", },
    {"<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "help_tags", },
    {"<leader>fe", function() require("telescope.builtin").treesitter() end, desc = "treesitter", },
    --{"<leader>fc", function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "current buffer fuzzy find", },
    {"<leader>ft", function() require("telescope.builtin").builtin() end, desc = "builtin", },
    --{"<leader>r", "<cmd>lua require('telescope').extensions.recent_files.pick()<cr>", desc = "recent files"},
    -- Bind <leader>; to reopen latest telescope window
    {"<leader>;", function() require("telescope.builtin").resume(require('telescope.themes').get_ivy({})) end, desc = "resume telescope"},
  },
}

return plugin
