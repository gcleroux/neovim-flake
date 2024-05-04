local icons_status_ok, icons = pcall(require, "nvim-web-devicons")
if not icons_status_ok then
    vim.notify("Plugin nvim-web-devicons is missing")
    return
end

icons.setup({
    -- your personal icons can go here (to override)
    -- you can specify color or cterm_color instead of specifying both of them
    -- DevIcon will be appended to `name`
    override = {
        dockerfile = {
            icon = "",
            color = "#0db7ed",
            name = "Dockerfile",
        },
        Makefile = {
            icon = "",
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
