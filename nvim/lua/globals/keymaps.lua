-- Functional wrapper for mapping custom keybindings
local function keymap(mode, lhs, rhs)
    local options = { noremap = true, silent = true }
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- TODO: Refactor this file into a directory with 1 file per extension keymaps

------------------------------
--    General keybindings   --
------------------------------

-- Normal --
-- Better window navigation
keymap("n", "<leader>q", ":Bdelete<CR>")
keymap("n", "<leader>Q", ":bufdo bwipeout<CR>")

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>")
keymap("n", "<C-Down>", ":resize -2<CR>")
keymap("n", "<C-Left>", ":vertical resize -2<CR>")
keymap("n", "<C-Right>", ":vertical resize +2<CR>")

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>")
keymap("n", "<S-h>", ":bprevious<CR>")

-- Visual --
-- Stay in indent mode
keymap("v", "<S-Tab>", "<gv")
keymap("v", "<Tab>", ">gv")

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==")
keymap("v", "<A-k>", ":m .-2<CR>==")
keymap("v", "p", '"_dP')

-- Visual Block --
-- Move text up and down
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv")
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv")

-- Telescope
keymap("n", "<leader>f", "<cmd>Telescope find_files<CR>")
keymap("n", "<leader>t", "<cmd>Telescope live_grep<cr>")

-- Toggle file tree (%:p:h opens at current buffer location)
keymap("n", "<C-\\>", "<cmd>NnnExplorer %:p:h<CR>")
keymap("t", "<C-\\>", "<cmd>NnnExplorer %:p:h<CR>")
keymap("n", "<leader>n", "<cmd>NnnPicker<CR>")

-- Generate docstring
keymap("n", "<leader>doc", ":Neogen<CR>")

-- Debugger keymaps
keymap("n", "<F5>", "<cmd>lua require'dap'.continue()<CR>")
keymap("n", "<F10>", "<cmd>lua require'dap'.step_over()<CR>")
keymap("n", "<F11>", "<cmd>lua require'dap'.step_into()<CR>")
keymap("n", "<F12>", "<cmd>lua require'dap'.step_out()<CR>")
keymap("n", "<leader>b", "<cmd>lua require'dap'.toggle_breakpoint()<CR>")
keymap("n", "<leader>B", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
keymap("n", "<leader>lp", ",<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
keymap("n", "<leader>dbg", "<cmd>lua require'dap'.repl.open()<CR>")
keymap("n", "<leader>rl", "<cmd>lua require'dap'.run_last()<CR>")

-- Gitsigns
keymap("n", "<leader>hr", ":Gitsigns reset_hunk<CR>")
keymap("n", "<leader>hp", ":Gitsigns preview_hunk<CR>")
keymap("n", "<leader>hn", ":Gitsigns next_hunk<CR>")
keymap("n", "<leader>hb", ":Gitsigns prev_hunk<CR>")

-- Pressing backspace in normal mode returns to previous opened file
keymap("n", "<bs>", ":edit #<CR>")
keymap("n", "<leader>L", ":noh<CR>")

keymap("n", "<leader>x", ":lua require('telescope').extensions.neoclip.default()<CR>")
