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

    --require("mason-null-ls").setup({
      --ensure_installed = { "stylua" },
    --})

    local nvim_lsp = require("lspconfig")
    nvim_lsp.neocmake.setup({
      cmd = { "neocmakelsp", "--stdio" },
      filetypes = { "cmake" },
      root_dir = function(fname)
        return nvim_lsp.util.find_git_ancestor(fname)
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
    require("lspconfig").tinymist.setup({
      settings = {
        formatterMode = "typstyle",
        exportPdf = "onType",
        semanticTokens = "disable",
      },
    })
    -- Needed to load the LSPs for some reason.
    -- https://old.reddit.com/r/neovim/comments/14cikep/on_nightly_my_lsp_is_not_starting_automatically/
    --vim.api.nvim_exec_autocmds("FileType", {})
  end,
}

return plugin
