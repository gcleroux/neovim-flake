-- Functional wrapper for mapping custom keybindings
local function keymap(mode, lhs, rhs)
    local options = { noremap = true, silent = true }
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

------------------------------
--    General keybindings   --
------------------------------
-- NOTE: keymaps that belong to a plugin live in that plugin's spec under
-- `lua/specs/`, so pressing the key is what loads the plugin.

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>")
keymap("n", "<S-h>", ":bprevious<CR>")

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>")
keymap("n", "<C-Down>", ":resize -2<CR>")
keymap("n", "<C-Left>", ":vertical resize -2<CR>")
keymap("n", "<C-Right>", ":vertical resize +2<CR>")

-- Visual --
-- Stay in indent mode
keymap("v", "<S-Tab>", "<gv")
keymap("v", "<Tab>", ">gv")

-- Move text up and down
keymap("v", "p", '"_dP')
keymap("v", "<A-j>", ":m .+1<CR>==")
keymap("v", "<A-k>", ":m .-2<CR>==")

-- Visual Block --
-- Move text up and down
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv")
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv")

-- Pressing backspace in normal mode returns to previous opened file
keymap("n", "<leader>L", ":noh<CR>")
