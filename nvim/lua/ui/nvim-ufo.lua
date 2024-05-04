local ufo_status_ok, ufo = pcall(require, "ufo")
if not ufo_status_ok then
    vim.notify("Plugin nvim-ufo is missing")
    return
end

ufo.setup()
