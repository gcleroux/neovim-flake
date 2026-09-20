-- Libraries and plugins with no startup work of their own: they are pulled in
-- the moment something requires them, or alongside the plugin that needs them.
return {
    { "plenary.nvim", on_require = "plenary" },
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
                -- your personal icons can go here (to override)
                -- you can specify color or cterm_color instead of specifying both of them
                -- DevIcon will be appended to `name`
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
                -- globally enable different highlight colors per icon (default to true)
                -- if set to false all icons will have the default icon's color
                color_icons = true,
                -- globally enable default icons (default to false)
                -- will get overridden by `get_icons` option
                default = true,
            })
        end,
    },
}
