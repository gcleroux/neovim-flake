-- Keymaps that belong to a plugin live in its spec under plugins/, so that
-- pressing the key is what loads the plugin.
local map = vim.keymap.set

map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Taller window" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shorter window" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Narrower window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Wider window" })

map("x", "<Tab>", ">gv", { desc = "Indent selection" })
map("x", "<S-Tab>", "<gv", { desc = "Unindent selection" })
map("x", "p", '"_dP', { desc = "Paste over selection without yanking it" })
map("x", "<A-j>", ":move '>+1<CR>gv-gv", { silent = true, desc = "Move selection down" })
map("x", "<A-k>", ":move '<-2<CR>gv-gv", { silent = true, desc = "Move selection up" })

map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment on line" })
map("x", "<C-/>", "gc", { remap = true, desc = "Toggle comment on selection" })

map("n", "<leader>L", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
