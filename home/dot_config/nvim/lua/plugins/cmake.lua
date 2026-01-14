return {
  "Civitasv/cmake-tools.nvim",
  enabled = function()
    local is_on = vim.g.cmake_tools_enabled
    return is_on and vim.fn.executable("cmake") == 1
  end,
  opts = {
    cmake_regenerate_on_save = false,
    cmake_build_directory = function()
      local osys = require("cmake-tools.osys")
      if osys.iswin32 then
        return "build\\${variant:buildType}"
      end
      return "build/${variant:buildType}"
    end,
  },
}
