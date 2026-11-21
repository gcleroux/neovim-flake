-- Libraries and plugins with no startup work of their own: they are pulled in
-- the moment something requires them, or alongside the plugin that needs them.
return {
    { "SchemaStore.nvim", on_require = "schemastore" },
    {
        "bufdelete.nvim",
        on_require = "bufdelete",
        keys = {
            {
                "<leader>q",
                function()
                    require("bufdelete").bufdelete()
                end,
                desc = "Close buffer",
            },
            {
                "<leader>Q",
                function()
                    vim.cmd("bufdo lua require('bufdelete').bufwipeout(0, true)")
                end,
                desc = "Close every buffer",
            },
        },
    },
    {
        "nvim-web-devicons",
        on_require = "nvim-web-devicons",
        after = function()
            require("nvim-web-devicons").setup({
                override = {
                    dockerfile = {
                        icon = "",
                        color = "#0db7ed",
                        name = "Dockerfile",
                    },
                    Makefile = {
                        icon = "",
                        color = "#428850",
                        name = "Makefile",
                    },
                },
                default = true,
            })
        end,
    },
}
