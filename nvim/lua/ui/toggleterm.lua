local toggleterm_status_ok, toggleterm = pcall(require, "toggleterm")
if not toggleterm_status_ok then
    vim.notify("Plugin toggleterm is missing")
    return
end

local terminal = require("toggleterm.terminal").Terminal

toggleterm.setup({
    open_mapping = [[<c-t>]],
    direction = "float",
    float_opts = {
        border = "single",
        width = function()
            return math.floor(vim.o.columns * 0.85)
        end,
        height = function()
            return math.floor(vim.o.lines * 0.85)
        end,
    },
})

local lazygit = terminal:new({
    cmd = "lazygit",
    dir = "git_dir",
    direction = "float",
    float_opts = {
        border = "single",
        width = function()
            return math.floor(vim.o.columns * 0.85)
        end,
        height = function()
            return math.floor(vim.o.lines * 0.85)
        end,
    },
    -- function to run on opening the terminal
    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
    -- function to run on closing the terminal
    on_close = function(term)
        vim.cmd("startinsert!")
    end,
})

local bottom = terminal:new({
    cmd = "btm",
    direction = "float",
    float_opts = {
        border = "single",
        width = function()
            return math.floor(vim.o.columns * 0.85)
        end,
        height = function()
            return math.floor(vim.o.lines * 0.85)
        end,
    },
    -- function to run on opening the terminal
    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
    -- function to run on closing the terminal
    on_close = function(term)
        vim.cmd("startinsert!")
    end,
})

local k9s = terminal:new({
    cmd = "k9s",
    direction = "float",
    float_opts = {
        border = "single",
        width = function()
            return math.floor(vim.o.columns * 0.85)
        end,
        height = function()
            return math.floor(vim.o.lines * 0.85)
        end,
    },
    -- function to run on opening the terminal
    on_open = function(term)
        vim.cmd("startinsert!")
    end,
    -- function to run on closing the terminal
    on_close = function(term)
        vim.cmd("startinsert!")
    end,
})

function _lazygit_toggle()
    lazygit:toggle()
end

function _bottom_toggle()
    bottom:toggle()
end

function _k9s_toggle()
    k9s:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>gg", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>mm", "<cmd>lua _bottom_toggle()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>kk", "<cmd>lua _k9s_toggle()<CR>", { noremap = true, silent = true })
