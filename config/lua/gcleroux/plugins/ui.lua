local float_opts = {
    border = "single",
    width = function()
        return math.floor(vim.o.columns * 0.85)
    end,
    height = function()
        return math.floor(vim.o.lines * 0.85)
    end,
}

local terminals = {
    ["<leader>gg"] = { cmd = "lazygit", dir = "git_dir", close_key = true },
    ["<leader>mm"] = { cmd = "btm", close_key = true },
    ["<leader>kk"] = { cmd = "k9s" },
}

local terminal_keys = {}
for lhs in pairs(terminals) do
    table.insert(terminal_keys, { lhs, mode = "n" })
end
table.insert(terminal_keys, { "<c-t>", mode = { "n", "i", "t" } })

return {
    {
        "bufferline.nvim",
        event = "DeferredUIEnter",
        after = function()
            require("bufferline").setup({
                options = {
                    close_command = false,
                    right_mouse_command = false,
                    left_mouse_command = false,
                    buffer_close_icon = "",
                    close_icon = "",
                    left_trunc_marker = "",
                    right_trunc_marker = "",
                    max_name_length = 30,
                    max_prefix_length = 30,
                    tab_size = 21,
                    diagnostics = "nvim_lsp",
                    diagnostics_update_in_insert = false,
                    diagnostics_indicator = function(count, level, _, _)
                        local icon = level:match("error") and " " or " "
                        return " " .. icon .. count
                    end,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    enforce_regular_tabs = true,
                },
            })
        end,
    },

    {
        "lualine.nvim",
        event = "DeferredUIEnter",
        after = function()
            require("lualine").setup({
                options = {
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                },
            })
        end,
    },

    {
        "oil.nvim",
        lazy = not (vim.fn.argc(-1) == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1),
        cmd = "Oil",
        on_require = "oil",
        keys = {
            { "<tab>", "<cmd>Oil<cr>", desc = "Open parent directory" },
        },
        after = function()
            require("oil").setup({
                win_options = { signcolumn = "yes" },
                skip_confirm_for_simple_edits = true,
                keymaps = {
                    ["<BS>"] = "actions.parent",
                    ["<C-t>"] = false,
                },
                float = {
                    preview_split = "right",
                },
            })
        end,
    },

    {
        "toggleterm.nvim",
        cmd = { "ToggleTerm", "TermExec" },
        keys = terminal_keys,
        after = function()
            require("toggleterm").setup({
                open_mapping = [[<c-t>]],
                direction = "float",
                float_opts = float_opts,
            })

            local Terminal = require("toggleterm.terminal").Terminal

            for lhs, spec in pairs(terminals) do
                local term = Terminal:new({
                    cmd = spec.cmd,
                    dir = spec.dir,
                    direction = "float",
                    float_opts = float_opts,
                    on_open = function(term)
                        vim.cmd("startinsert!")
                        if spec.close_key then
                            vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = term.bufnr, desc = "Close terminal" })
                        end
                    end,
                })

                vim.keymap.set("n", lhs, function()
                    term:toggle()
                end, { desc = spec.cmd })
            end
        end,
    },
}
