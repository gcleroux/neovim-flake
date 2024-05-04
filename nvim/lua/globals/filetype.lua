local treesitter_status_ok, _ = pcall(require, "nvim-treesitter")
if not treesitter_status_ok then
    vim.notify("Plugin nvim-treesitter is missing")
    return
end

-- Adding custom filetypes for runtime linting and syntax highlighting
vim.filetype.add({
    filename = {
        [".env"] = "env",
    },
})
vim.treesitter.language.register("bash", "env")
