local copilot_status_ok, copilot = pcall(require, "copilot")
if not copilot_status_ok then
    vim.notify("Plugin copilot is missing")
    return
end

copilot.setup({
    -- Disabling panel and suggestion as it can interfere with copilot-cmp
    panel = {
        enabled = false,
    },
    suggestion = {
        enabled = false,
    },
    filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false,
    },
    copilot_node_command = "node", -- Node.js version must be > 16.x
    server_opts_overrides = {},
})
