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
                    ["<CR>"] = { "accept", "fallback" },
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

            -- Clears the snippet buffer when leaving snippet mode
            -- This prevents the cursor from jumping to previously exited snippets
            -- that weren't completed
            local function leave_snippet()
                if
                    ((vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n") or vim.v.event.old_mode == "i")
                    and luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
                    and not luasnip.session.jump_active
                then
                    luasnip.unlink_current()
                end
            end

            -- stop snippets when you leave to normal mode
            vim.api.nvim_create_autocmd("ModeChanged", {
                group = vim.api.nvim_create_augroup("luasnip_leave", { clear = true }),
                callback = leave_snippet,
            })
        end,
    },
    { "friendly-snippets", dep_of = "luasnip" },

    {
        "nvim-autopairs",
        event = "InsertEnter",
        after = function()
            require("nvim-autopairs").setup({
                check_ts = true,
                ts_config = {
                    lua = { "string", "source" },
                },
                fast_wrap = {
                    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
                    highlight = "PmenuSel",
                    highlight_grey = "LineNr",
                },
            })
        end,
    },
}
