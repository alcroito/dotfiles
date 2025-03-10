local plugin = {
  -- LSP manager
  "williamboman/mason.nvim",
  event = 'VeryLazy',
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("mason").setup()
    require'mason-lspconfig'.setup{
      ensure_installed = {"harper_ls", "tinymist"}
    }
    require'lspconfig'.harper_ls.setup {
      filetypes = {"gitcommit", "markdown"},
      settings = {
        ["harper-ls"] = {
          userDictPath = '~/.vim/spell/en.utf-8.add',
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
              terminating_conjunctions = true
          }
        }
      }
    }
    require'lspconfig'.tinymist.setup {
      settings = {
        formatterMode = "typstyle",
        exportPdf = "onType",
        semanticTokens = "disable"
      }
    }
  end,
}

return plugin
