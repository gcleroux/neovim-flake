-- Adding custom filetypes for runtime linting and syntax highlighting
vim.filetype.add({
    filename = {
        [".env"] = "env",
    },
})
vim.treesitter.language.register("bash", "env")
