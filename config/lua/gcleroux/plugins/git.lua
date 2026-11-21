-- Git integration. gitsigns needs to attach to buffers to draw its signs, so
-- it comes up as soon as the UI is ready; diffview is command/key driven.
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

    -- diffview-plus.nvim, a maintained fork of diffview.nvim. Its lua module
    -- is still `diffview`. Mappings are the upstream recommended <leader>d set.
    {
        "diffview-plus.nvim",
        cmd = {
            "DiffviewOpen",
            "DiffviewToggle",
            "DiffviewFileHistory",
            "DiffviewDiffFiles",
            "DiffviewMergeFiles",
            "DiffviewDiffDirs",
            "DiffviewLog",
        },
        on_require = "diffview",
        keys = {
            { "<leader>dv", "<cmd>DiffviewToggle<cr>", desc = "Diffview: toggle" },
            { "<leader>do", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
            { "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
            { "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
            { "<leader>dH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: repo history" },
            { "<leader>dl", "<cmd>.DiffviewFileHistory --follow<cr>", desc = "Diffview: line history" },
            {
                "<leader>dh",
                "<Esc><cmd>'<,'>DiffviewFileHistory --follow<cr>",
                mode = "v",
                desc = "Diffview: selection history",
            },
            {
                "<leader>dm",
                function()
                    vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", "main" })
                    vim.cmd.DiffviewOpen(vim.v.shell_error == 0 and "main" or "master")
                end,
                desc = "Diffview: diff against main/master",
            },
        },
        after = function()
            -- Defaults are kept for everything not listed; `g?` inside any
            -- diffview buffer lists the mappings. See :h diffview.defaults
            require("diffview").setup({
                enhanced_diff_hl = true,
                view = {
                    merge_tool = { layout = "diff3_mixed" },
                },
                file_panel = {
                    listing_style = "tree",
                    win_config = { position = "left", width = 35 },
                },
                keymaps = {
                    view = {
                        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
                    },
                    file_panel = {
                        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
                    },
                    file_history_panel = {
                        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
                    },
                },
            })
        end,
    },
}
