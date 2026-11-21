-- Git integration. gitsigns needs to attach to buffers to draw its signs, so
-- it comes up as soon as the UI is ready; diffview is command/key driven.
return {
    {
        "gitsigns.nvim",
        event = "DeferredUIEnter",
        after = function()
            require("gitsigns").setup({
                signs = {
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                },
                attach_to_untracked = true,
                current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
                preview_config = { border = "single" },
            })

            local function map(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { desc = desc })
            end

            map("<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", "Reset hunk")
            map("<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", "Preview hunk")
            map("<leader>hn", "<cmd>Gitsigns nav_hunk next<CR>", "Next hunk")
            map("<leader>hb", "<cmd>Gitsigns nav_hunk prev<CR>", "Previous hunk")
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
            require("diffview").setup({
                enhanced_diff_hl = true,
                view = {
                    merge_tool = { layout = "diff3_mixed" },
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
