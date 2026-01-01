-- Optionally load local configuration if it exists
pcall(require, "config.local_machine")

require("config.lazy")
