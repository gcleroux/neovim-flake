require("gcleroux.options")
require("gcleroux.keymaps")
require("gcleroux.commands")
require("gcleroux.plugins")

-- Keeps resolving every server config and spawning servers off the first draw.
vim.api.nvim_create_autocmd("User", {
    pattern = "DeferredUIEnter",
    once = true,
    callback = function()
        require("gcleroux.lsp")
    end,
})
