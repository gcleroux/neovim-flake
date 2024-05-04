-- Setup global config
require("globals")

-- Plugins config
require("plugins")

-- Set up the colorscheme (comes before ui)
require("themes.nordfox")

-- Set up the UI
require("ui")

-- Debuggers config
require("debuggers")

-- Set up LSP (Should be loaded last)
require("lsp")
