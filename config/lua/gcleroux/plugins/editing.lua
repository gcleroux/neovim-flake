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
    ["]k"] = { "goto_next_start", "@class.outer", "textobjects" },
    ["]K"] = { "goto_next_end", "@class.outer", "textobjects" },
    ["[k"] = { "goto_previous_start", "@class.outer", "textobjects" },
    ["[K"] = { "goto_previous_end", "@class.outer", "textobjects" },
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
        "nvim-surround",
        keys = {
            { "ys", mode = "n" },
            { "cs", mode = "n" },
            { "ds", mode = "n" },
            { "S", mode = "x" },
        },
        after = function()
            require("nvim-surround").setup()
        end,
    },

    {
        "neogen",
        cmd = "Neogen",
        keys = {
            { "<leader>cd", "<cmd>Neogen<cr>", desc = "Generate docstring" },
        },
        after = function()
            require("neogen").setup({ snippet_engine = "luasnip" })
        end,
    },

    {
        "nvim-treesitter-textobjects",
        keys = textobject_keys,
        after = function()
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true },
            })

            for lhs, spec in pairs(selects) do
                vim.keymap.set({ "x", "o" }, lhs, function()
                    require("nvim-treesitter-textobjects.select").select_textobject(spec[1], spec[2])
                end, { desc = "Select " .. spec[1] })
            end

            for lhs, spec in pairs(moves) do
                vim.keymap.set({ "n", "x", "o" }, lhs, function()
                    require("nvim-treesitter-textobjects.move")[spec[1]](spec[2], spec[3])
                end, { desc = spec[1]:gsub("_", " ") .. " " .. spec[2] })
            end
        end,
    },

    {
        "vim-suda",
        cmd = { "SudaRead", "SudaWrite" },
    },
}
