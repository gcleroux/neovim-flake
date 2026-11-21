require("gcleroux.plugins.startup")

local enabled = require("gcleroux.settings").specs
local imports = {}
for _, group in ipairs({ "deps", "completion", "editing", "ui", "finder", "git", "format", "lint", "dap", "markdown" }) do
    if enabled[group] ~= false then
        table.insert(imports, { import = "gcleroux.plugins." .. group })
    end
end
require("lze").load(imports)
