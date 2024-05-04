local cursorline_status_ok, cursorline = pcall(require, "nvim-cursorline")
if not cursorline_status_ok then
    vim.notify("Plugin cursorline is missing")
    return
end

cursorline.setup({
    cursorline = {
        enable = true,
        timeout = 1000,
        number = false,
    },
    cursorword = {
        enable = true,
        min_length = 3,
        hl = { underline = true },
    },
})
