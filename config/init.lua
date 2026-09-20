-- Entry point of the configuration.
--
-- Sourced by the Nix wrapper, which prepends `vim.g.nvim_settings` with the
-- build-time settings (see nix/neovim.nix). Everything below is plain
-- Neovim Lua: nothing here knows about Nix.

-- Editor options, keymaps and commands
require("globals")

-- Colorscheme (must come before any UI plugin is configured)
require("themes.nordfox")

-- Treesitter is loaded eagerly, its highlighting hooks into FileType
require("treesitter")

-- Every other plugin: lze specs, loaded on demand
require("specs")

-- Standalone helpers
require("utils")
