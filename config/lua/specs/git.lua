-- Git integration. gitsigns needs to attach to buffers to draw its signs, so
-- it comes up as soon as the UI is ready; the rest is command driven.
return {
    {
        "gitsigns.nvim",
        event = "DeferredUIEnter",
        after = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "┃" },
                    change = { text = "┃" },
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                    changedelete = { text = "~" },
                    untracked = { text = "┆" },
                },
                signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
                numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
                linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
                word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
                watch_gitdir = {
                    interval = 1000,
                    follow_files = true,
                },
                attach_to_untracked = true,
                current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                    delay = 1000,
                    ignore_whitespace = false,
                },
                current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
                sign_priority = 6,
                update_debounce = 100,
                status_formatter = nil, -- Use default
                max_file_length = 40000, -- Disable if file is longer than this (in lines)
                preview_config = {
                    -- Options passed to nvim_open_win
                    border = "single",
                    style = "minimal",
                    relative = "cursor",
                    row = 0,
                    col = 1,
                },
            })

            local keymap = function(lhs, rhs)
                vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true })
            end

            keymap("<leader>hr", ":Gitsigns reset_hunk<CR>")
            keymap("<leader>hp", ":Gitsigns preview_hunk<CR>")
            keymap("<leader>hn", ":Gitsigns next_hunk<CR>")
            keymap("<leader>hb", ":Gitsigns prev_hunk<CR>")
        end,
    },
}
