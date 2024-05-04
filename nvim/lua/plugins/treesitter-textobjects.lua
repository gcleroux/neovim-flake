local ts_txtobj_status_ok, ts_txtobj = pcall(require, "nvim-treesitter.configs")
if not ts_txtobj_status_ok then
    vim.notify("Plugin nvim-treesitter is missing")
    return
end

local ts_repeat_move_status_ok, ts_repeat_move = pcall(require, "nvim-treesitter.textobjects.repeatable_move")
if not ts_repeat_move_status_ok then
    vim.notify("Plugin nvim-treesitter.textobjects.repeatable_move is missing")
    return
end

-- Making jumps repeatable with f,F,t,T
--vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
--vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
--vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
--vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)

ts_txtobj.setup({
    textobjects = {
        select = {
            enable = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]f"] = "@function.outer",
                ["]c"] = "@class.outer",
                ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
                ["]F"] = "@function.outer",
                ["]C"] = "@class.outer",
                ["]S"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                ["]Z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[c"] = "@class.outer",
                ["[s"] = { query = "@scope", query_group = "locals", desc = "Previous scope" },
                ["[z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
            },
            goto_previous_end = {
                ["[F"] = "@function.outer",
                ["[C"] = "@class.outer",
                ["[S"] = { query = "@scope", query_group = "locals", desc = "Previous scope" },
                ["[Z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
                ["]o"] = "@conditional.outer",
            },
            goto_previous = {
                ["[o"] = "@conditional.outer",
            },
        },
        lsp_interop = {
            enable = true,
            border = "none",
            floating_preview_opts = {},
            peek_definition_code = {
                ["<leader>df"] = "@function.outer",
                ["<leader>dc"] = "@class.outer",
            },
        },
    },
})
