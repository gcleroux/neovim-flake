local function hide_in_snippet(cmp)
    if require("luasnip").locally_jumpable(1) then
        return cmp.hide()
    end
end

local function show_after_word(cmp)
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col > 0 and not vim.api.nvim_get_current_line():sub(col, col):match("%s") then
        return cmp.show()
    end
end

return {
    {
        "blink.cmp",
        -- setup() finishes asynchronously, so loading it on InsertEnter would
        -- drop the first keys typed.
        event = "DeferredUIEnter",
        after = function()
            require("blink.cmp").setup({
                keymap = {
                    preset = "none",
                    ["<Tab>"] = { "select_next", "snippet_forward", show_after_word, "fallback" },
                    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                    ["<CR>"] = { "accept", hide_in_snippet, "fallback" },
                    ["<C-a>"] = { "show" },
                    ["<C-e>"] = { "cancel", "fallback" },
                    ["<C-j>"] = { "scroll_documentation_down", "fallback" },
                    ["<C-k>"] = { "scroll_documentation_up", "fallback" },
                },
                completion = {
                    list = { selection = { preselect = false } },
                    documentation = { auto_show = true },
                    menu = {
                        draw = {
                            columns = {
                                { "label", "label_description", gap = 1 },
                                { "kind_icon", "kind", gap = 1 },
                                { "source_name" },
                            },
                        },
                    },
                },
                snippets = { preset = "luasnip" },
                sources = {
                    default = { "lsp", "snippets", "buffer", "path", "emoji" },
                    providers = {
                        emoji = { name = "Emoji", module = "blink-emoji" },
                    },
                },
                cmdline = { enabled = false },
            })
        end,
    },
    { "blink-emoji.nvim", on_require = "blink-emoji" },

    {
        "luasnip",
        event = "InsertEnter",
        on_require = "luasnip",
        after = function()
            local luasnip = require("luasnip")

            -- Load snippets from rafamadriz/friendly-snippets
            require("luasnip.loaders.from_vscode").lazy_load()

            -- Load the snippets shipped with this config (config/luasnippets)
            require("luasnip.loaders.from_vscode").lazy_load({
                paths = vim.api.nvim_get_runtime_file("luasnippets", true),
            })

            -- Leaving to normal mode ends the snippet, so <Tab> cannot later jump
            -- back into one that was abandoned halfway. Only normal mode: accepting
            -- a completion passes through the ic/ix submodes inside the snippet.
            vim.api.nvim_create_autocmd("ModeChanged", {
                group = vim.api.nvim_create_augroup("luasnip_leave", { clear = true }),
                pattern = "*:n",
                callback = function()
                    if
                        luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
                        and not luasnip.session.jump_active
                    then
                        luasnip.unlink_current()
                    end
                end,
            })
        end,
    },
    { "friendly-snippets", dep_of = "luasnip" },

    {
        "nvim-autopairs",
        event = "InsertEnter",
        after = function()
            local npairs = require("nvim-autopairs")
            npairs.setup({
                check_ts = true,
                fast_wrap = {
                    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
                    highlight = "PmenuSel",
                    highlight_grey = "LineNr",
                },
            })

            for _, pair in ipairs({ '"', "'", "`" }) do
                npairs.remove_rule(pair)
            end
        end,
    },
}
