-- Lazy loading.
--
-- Every plugin below lives in `pack/*/opt` (see nix/plugins.nix), so nothing
-- of it is on the runtimepath until one of its triggers fires. lze then runs
-- `:packadd` followed by the spec's `after` hook, which holds what used to be
-- the plugin's config file.
--
-- Triggers in use:
--   event = "DeferredUIEnter"  right after the UI is up, off the startup path
--   event = "InsertEnter"      completion machinery
--   event = "BufReadPost"      anything that needs a real file
--   ft / cmd / keys            on first use
--   on_require                 when any Lua module of the plugin is required
--   dep_of                     pulled in with the plugin that needs it
--
-- Plugins deliberately left eager, in pack/*/start: lze itself, the
-- colorscheme, nvim-treesitter (highlighting must be up before the first
-- draw) and rainbow-delimiters (it hooks FileType at startup).

-- `:packadd` sources a plugin's plugin/ files but NOT its after/plugin/ ones
-- once startup is over. Every nvim-cmp source registers itself from
-- after/plugin/, so without this they load but never register, and cmp
-- reports "unknown source name" for all of them.
vim.g.lze = {
    load = function(name)
        vim.cmd.packadd(name)
        for _, dir in ipairs(vim.fn.globpath(vim.o.packpath, "pack/*/opt/" .. name, false, true)) do
            for _, file in ipairs(vim.fn.glob(dir .. "/after/plugin/**/*.{lua,vim}", false, true)) do
                vim.cmd.source(file)
            end
        end
    end,
}

require("lze").load({
    { import = "specs.deps" },
    { import = "specs.completion" },
    { import = "specs.editing" },
    { import = "specs.ui" },
    { import = "specs.finder" },
    { import = "specs.git" },
    { import = "specs.lsp" },
    { import = "specs.dap" },
    { import = "specs.markdown" },
})

-- `nvim <dir>` should still land in oil, which cannot happen if oil is only
-- loaded by its keymap.
if vim.fn.argc(-1) == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
    require("lze").trigger_load("oil.nvim")
end
