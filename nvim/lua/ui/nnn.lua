local nnn_status_ok, nnn = pcall(require, "nnn")
if not nnn_status_ok then
    vim.notify("Plugin nnn is missing")
    return
end

local function copy_to_clipboard(lines)
    local joined_lines = table.concat(lines, "\n")
    vim.fn.setreg("+", joined_lines)
end

local function cd_selected_dir(lines)
    local dir = lines[#lines]
    if vim.fn.filereadable(dir) == 1 then
        dir = vim.fn.fnamemodify(dir, ":h")
    end
    vim.api.nvim_command("cd " .. vim.fn.shellescape(dir))
end

-- Exit Neovim if NnnExplorer is the only window remaining in the only tab.
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "*",
    command = "if tabpagenr('$') == 1 && winnr('$') == 1 && &filetype ==# 'nnn' | quit! | endif",
})

-- Close the tab if NnnExplorer is the only window remaining in it.
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "*",
    command = "if winnr('$') == 1 && &filetype ==# 'nnn' | quit! | endif",
})

-- https://github.com/mcchrish/nnn.vim?tab=readme-ov-file#troubleshooting
-- Fix for nnn :wqa [E948: Job still running]
vim.cmd([[command Z w | qa]])
vim.cmd([[cabbrev wqa Z]])

nnn.setup({
    command = "nnn -o",
    explorer_layout = { left = "~25%" },
    set_default_mappings = 0,
    replace_netrw = "1",
    action = {
        ["<C-t>"] = "tab split",
        ["<C-h>"] = "split",
        ["<C-v>"] = "vsplit",
        ["<C-w>"] = "wincmd j",
        ["<C-y>"] = copy_to_clipboard,
        ["<C-c>"] = cd_selected_dir,
    },
})
