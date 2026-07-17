local plugin = {
  -- LSP manager
  "williamboman/mason.nvim",
  --event = 'VeryLazy',
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "jay-babu/mason-null-ls.nvim",
    "nvimtools/none-ls.nvim",
  },
  config = function()
    require("mason").setup()
    --require("mason-lspconfig").setup({
      --ensure_installed = { "harper_ls", "tinymist", "basedpyright" },
    --})
    require("mason-lspconfig").setup({})

    --require("mason-null-ls").setup({
      --ensure_installed = { "stylua" },
    --})

    vim.lsp.config("neocmake", {
      cmd = { "neocmakelsp", "--stdio" },
      filetypes = { "cmake" },
      root_dir = function(fname)
        return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
      end,
      single_file_support = true, -- suggested
      init_options = {
        format = {
          enable = false,
        },
        lint = {
          enable = false,
        },
        scan_cmake_in_package = true, -- default is true
      },
    })

    vim.lsp.config("basedpyright", {
      settings = {
        basedpyright = {
          analysis = {
            typeCheckingMode = "off", -- "off", "basic", "strict"
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      },
    })

    -- neovim 0.11+ syntax
    vim.lsp.config("harper_ls", {
      filetypes = { "gitcommit", "git-commit", "markdown" },
      settings = {
        ["harper-ls"] = {
          userDictPath = vim.fn.expand("$HOME/.vim/spell/en.utf-8.add"),
          linters = {
            spell_check = true,
            spelled_numbers = false,
            an_a = true,
            sentence_capitalization = true,
            unclosed_quotes = true,
            wrong_quotes = false,
            long_sentences = true,
            repeated_words = true,
            spaces = true,
            matcher = true,
            correct_number_suffix = true,
            number_suffix_capitalization = true,
            multiple_sequential_pronouns = true,
            linking_verbs = false,
            avoid_curses = true,
            terminating_conjunctions = true,
          },
          diagnosticSeverity = "hint",
        },
      },
    })
    vim.lsp.config("tinymist", {
      settings = {
        formatterMode = "typstyle",
        exportPdf = "onType",
        semanticTokens = "disable",
      },
    })

    -- When editing a Qt source file under ~/Dev/qt/worktrees/dev, point clangd at
    -- the matching per-module build dir under ~/Dev/qt/builds/dev-mac. The nearest
    -- git repo (clangd's root_dir, resolved via the .git marker) is the module dir;
    -- its basename maps to a build dir of the same name that holds compile_commands.json.
    vim.lsp.config("clangd", {
      before_init = function(init_params, config)
        local root = config.root_dir
        if not root and init_params.rootUri ~= vim.NIL then
          root = vim.uri_to_fname(init_params.rootUri)
        end
        if not root then
          return
        end
        root = vim.fs.normalize(root)

        local worktree = vim.fs.normalize("~/Dev/qt/worktrees/dev")
        if root ~= worktree and not vim.startswith(root, worktree .. "/") then
          return
        end

        local build_dir = vim.fs.normalize("~/Dev/qt/builds/dev-mac") .. "/" .. vim.fs.basename(root)
        if vim.fn.isdirectory(build_dir) == 1 then
          init_params.initializationOptions = init_params.initializationOptions or {}
          init_params.initializationOptions.compilationDatabasePath = build_dir
        end
      end,
    })
    -- Needed to load the LSPs for some reason.
    -- https://old.reddit.com/r/neovim/comments/14cikep/on_nightly_my_lsp_is_not_starting_automatically/
    --vim.api.nvim_exec_autocmds("FileType", {})
  end,
}

return plugin
