return {
  -- The default root_markers include "build" and "cmake", which pick a subdirectory in Qt repos.
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, ".git")
    if root then
      on_dir(root)
    end
  end,
  init_options = {
    format = {
      enable = false,
    },
    lint = {
      enable = false,
    },
    scan_cmake_in_package = true, -- default is true
  },
}
