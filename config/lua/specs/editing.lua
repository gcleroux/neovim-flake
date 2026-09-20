-- Text editing plugins. All of them only add mappings or commands, so they
-- load on first use.

-- lhs -> { query, query_group }
local selects = {
    ["af"] = { "@function.outer", "textobjects" },
    ["if"] = { "@function.inner", "textobjects" },
    ["ac"] = { "@class.outer", "textobjects" },
    ["ic"] = { "@class.inner", "textobjects" },
    ["as"] = { "@local.scope", "locals" },
}

-- lhs -> { move function name, query, query_group }
local moves = {
    ["]f"] = { "goto_next_start", "@function.outer", "textobjects" },
    ["]F"] = { "goto_next_end", "@function.outer", "textobjects" },
    ["[f"] = { "goto_previous_start", "@function.outer", "textobjects" },
    ["[F"] = { "goto_previous_end", "@function.outer", "textobjects" },
    ["]c"] = { "goto_next_start", "@class.outer", "textobjects" },
    ["]C"] = { "goto_next_end", "@class.outer", "textobjects" },
    ["[c"] = { "goto_previous_start", "@class.outer", "textobjects" },
    ["[C"] = { "goto_previous_end", "@class.outer", "textobjects" },
    ["]s"] = { "goto_next_start", "@local.scope", "locals" },
    ["[s"] = { "goto_previous_start", "@local.scope", "locals" },
}

local textobject_keys = {}
for lhs in pairs(selects) do
    table.insert(textobject_keys, { lhs, mode = { "x", "o" } })
end
for lhs in pairs(moves) do
    table.insert(textobject_keys, { lhs, mode = { "n", "x", "o" } })
end

return {
    {
        "comment.nvim",
        keys = {
            { "<C-/>", mode = { "n", "v" } },
            { "gc", mode = { "n", "v" } },
            { "gb", mode = { "n", "v" } },
        },
        after = function()
            require("Comment").setup({
                ---Add a space b/w comment and the line
                padding = true,
                ---Whether the cursor should stay at its position
                sticky = true,
                ---LHS of toggle mappings in NORMAL mode
                toggler = {
                    ---Line-comment toggle keymap <C-/>
                    line = "<C-/>",
                },
                ---LHS of operator-pending mappings in NORMAL and VISUAL mode
                opleader = {
                    ---Line-comment toggle keymap <C-/>
                    line = "<C-/>",
                },
                ---Enable keybindings
                ---NOTE: If given `false` then the plugin won't create any mappings
                mappings = {
                    ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
                    basic = true,
                    ---Extra mapping; `gco`, `gcO`, `gcA`
                    extra = false,
                },
            })
        end,
    },

    {
        "nvim-surround",
        keys = {
            { "ys", mode = "n" },
            { "cs", mode = "n" },
            { "ds", mode = "n" },
            { "S", mode = "x" },
        },
        after = function()
            require("nvim-surround").setup({
                -- Empty for default config
            })
        end,
    },

    {
        "neogen",
        cmd = "Neogen",
        keys = {
            { "<leader>doc", "<cmd>Neogen<cr>", desc = "Generate docstring" },
        },
        after = function()
            require("neogen").setup({
                snippet_engine = "luasnip",
                enabled = true,
                languages = {
                    lua = {
                        template = {
                            annotation_convention = "emmylua",
                        },
                    },
                    python = {
                        template = {
                            annotation_convention = "google_docstrings",
                        },
                    },
                },
            })
        end,
    },

    {
        "nvim-treesitter-textobjects",
        keys = textobject_keys,
        after = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    lookahead = true,
                    include_surrounding_whitespace = false,
                },
                move = {
                    set_jumps = true,
                },
                lsp_interop = {
                    border = "none",
                    floating_preview_opts = {},
                },
            })

            -- Select textobjects
            for lhs, spec in pairs(selects) do
                vim.keymap.set({ "x", "o" }, lhs, function()
                    require("nvim-treesitter-textobjects.select").select_textobject(spec[1], spec[2])
                end)
            end

            -- Move textobjects
            for lhs, spec in pairs(moves) do
                vim.keymap.set({ "n", "x", "o" }, lhs, function()
                    require("nvim-treesitter-textobjects.move")[spec[1]](spec[2], spec[3])
                end)
            end
        end,
    },

    {
        "vim-suda",
        cmd = { "SudaRead", "SudaWrite" },
    },
}
