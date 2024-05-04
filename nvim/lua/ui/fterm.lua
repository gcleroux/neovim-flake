local fterm_status_ok, fterm = pcall(require, "FTerm")
if not fterm_status_ok then
    vim.notify("Plugin fterm is missing")
    return
end

fterm.setup({
    border = "double",
    dimensions = {
        height = 0.9,
        width = 0.9,
    },
})

local bottom = fterm:new({
    ft = "btm", -- You can also override the default filetype, if you want
    cmd = "btm",
    dimensions = {
        height = 0.9,
        width = 0.9,
    },
})

-- Use this to toggle bottom in a floating terminal
vim.keymap.set("n", "<A-b>", function()
    bottom:toggle()
end)
