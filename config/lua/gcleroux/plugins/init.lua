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

local enabled = require("gcleroux.settings").specs
local imports = {}
for _, group in ipairs({ "deps", "completion", "editing", "ui", "finder", "git", "format", "lint", "dap", "markdown" }) do
    if enabled[group] ~= false then
        table.insert(imports, { import = "gcleroux.plugins." .. group })
    end
end
require("lze").load(imports)
