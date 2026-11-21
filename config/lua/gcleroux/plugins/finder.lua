-- fzf-lua is the picker used everywhere (LSP keymaps, neoclip, the CRD
-- helper), so `on_require` matters at least as much as its own keymaps.
return {
    {
        "fzf-lua",
        cmd = "FzfLua",
        on_require = "fzf-lua",
        keys = {
            { "<leader>f", "<cmd>FzfLua files<cr>", desc = "Find files" },
            { "<leader>t", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
        },
        after = function()
            require("fzf-lua").setup({
                winopts = { preview = { default = "bat" } },
                manpages = { previewer = "man_native" },
                helptags = { previewer = "help_native" },
                lsp = { code_actions = { previewer = "codeaction_native" } },
                tags = { previewer = "bat" },
                btags = { previewer = "bat" },
            })
        end,
    },

    {
        "nvim-neoclip.lua",
        on_require = "neoclip",
        keys = {
            {
                "<leader>x",
                function()
                    require("neoclip.fzf")('"')
                end,
                desc = "Clipboard history",
            },
        },
        after = function()
            require("neoclip").setup({ default_register = "+" })
        end,
    },
}
