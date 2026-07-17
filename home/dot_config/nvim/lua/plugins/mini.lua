return {
  "echasnovski/mini.nvim",
  version = false,
  event = "VeryLazy",
  config = function()
    --  Mini surround instead of sandwhich
    require("mini.surround").setup({
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    })

    local spec_treesitter = require("mini.ai").gen_spec.treesitter
    require('mini.extra').setup()
    require("mini.ai").setup({
      n_lines = 500,
      custom_textobjects = {
        -- Makes `aB` equivalent to built-in `al`
        B = MiniExtra.gen_ai_spec.buffer(),
        -- Makes `iL` equivalent to built-in `il`
        L = MiniExtra.gen_ai_spec.line(),

        F = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
        c = spec_treesitter({ a = "@class.outer", i = "@class.inner" }),
        o = spec_treesitter({
          a = { "@conditional.outer", "@loop.outer" },
          i = { "@conditional.inner", "@loop.inner" },
        }),
      },
    })

    -- Describe mini.ai text objects in which-key, adapted from LazyVim's
    -- lazyvim.util.mini.ai_whichkey. Object list matches the built-in and
    -- custom text objects configured above.
    local function ai_whichkey()
      local objects = {
        { " ", desc = "whitespace" },
        { '"', desc = '" string' },
        { "'", desc = "' string" },
        { "`", desc = "` string" },
        { "(", desc = "() block" },
        { ")", desc = "() block with ws" },
        { "[", desc = "[] block" },
        { "]", desc = "[] block with ws" },
        { "{", desc = "{} block" },
        { "}", desc = "{} with ws" },
        { "<", desc = "<> block" },
        { ">", desc = "<> block with ws" },
        { "?", desc = "user prompt" },
        { "a", desc = "argument" },
        { "b", desc = ")]} block" },
        { "q", desc = "quote ` \" '" },
        { "t", desc = "tag" },
        { "f", desc = "function call" },
        { "B", desc = "buffer" },
        { "L", desc = "line" },
        { "F", desc = "function" },
        { "c", desc = "class" },
        { "o", desc = "block, conditional, loop" },
      }

      local ret = { mode = { "o", "x" } }
      local mappings = {
        around = "a",
        inside = "i",
        around_next = "an",
        inside_next = "in",
        around_last = "al",
        inside_last = "il",
      }

      for name, prefix in pairs(mappings) do
        name = name:gsub("^around_", ""):gsub("^inside_", "")
        ret[#ret + 1] = { prefix, group = name }
        for _, obj in ipairs(objects) do
          local desc = obj.desc
          if prefix:sub(1, 1) == "i" then
            desc = desc:gsub(" with ws", "")
          end
          ret[#ret + 1] = { prefix .. obj[1], desc = desc }
        end
      end
      require("which-key").add(ret, { notify = false })
    end

    vim.schedule(function()
      if pcall(require, "which-key") then
        ai_whichkey()
      end
    end)

    --require("mini.completion").setup({
    --delay = { completion = 300, info = 100, signature = 50 },
    --})

    -- Mini files, for navigating files
    -- Disabled for now
    -- require('mini.files').setup()
    -- "lua vim.keymap.set("n", "<leader>m", "<cmd>lua MiniFiles.open()<cr>", opts)
  end,
}
