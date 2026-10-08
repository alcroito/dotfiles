-- When editing a Qt source file under ~/Dev/qt/worktrees/dev, point clangd at
-- the matching per-module build dir under ~/Dev/qt/builds/dev-mac. The nearest
-- git repo (clangd's root_dir, resolved via the .git marker) is the module dir;
-- its basename maps to a build dir of the same name that holds compile_commands.json.
return {
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
}
