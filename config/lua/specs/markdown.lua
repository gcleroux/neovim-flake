return {
    {
        "render-markdown.nvim",
        ft = { "markdown", "codecompanion", "Avante" },
        after = function()
            require("render-markdown").setup({})
        end,
    },

    {
        "vim-markdown-toc",
        cmd = {
            "GenTocGFM",
            "GenTocRedcarpet",
            "GenTocGitLab",
            "GenTocMarked",
            "UpdateToc",
            "RemoveToc",
        },
    },
}
