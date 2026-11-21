require("gcleroux.plugins.startup")

-- `:packadd` after startup does not source a plugin's after/plugin/ files,
-- which is where every nvim-cmp source registers itself.
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
    { import = "gcleroux.plugins.deps" },
    { import = "gcleroux.plugins.completion" },
    { import = "gcleroux.plugins.editing" },
    { import = "gcleroux.plugins.ui" },
    { import = "gcleroux.plugins.finder" },
    { import = "gcleroux.plugins.git" },
    { import = "gcleroux.plugins.lsp" },
    { import = "gcleroux.plugins.dap" },
    { import = "gcleroux.plugins.markdown" },
})

if vim.fn.argc(-1) == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
    require("lze").trigger_load("oil.nvim")
end
