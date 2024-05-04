local luasnip_status_ok, luasnip = pcall(require, "luasnip")
if not luasnip_status_ok then
    vim.notify("Plugin luasnip is missing")
    return
end

-- Load snippets from rafamadriz/friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- Load custom snippets
require("luasnip.loaders.from_vscode").lazy_load({ paths = "./snippets" })

-- Clears the snippet buffer when leaving snippet mode
-- This prevents the cursor from jumping to previously exited snippets that weren't completed
function leave_snippet()
    if ((vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n") or vim.v.event.old_mode == "i")
        and luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
        and not luasnip.session.jump_active
    then
        luasnip.unlink_current()
    end
end

-- stop snippets when you leave to normal mode
vim.api.nvim_command([[
    autocmd ModeChanged * lua leave_snippet()
]])
