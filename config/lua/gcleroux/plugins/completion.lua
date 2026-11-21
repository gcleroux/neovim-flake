-- Completion stack. nvim-cmp and luasnip both come up on the first insert;
-- the cmp sources and friendly-snippets ride along as dependencies.

local kind_icons = {
    Text = "",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰇽",
    Variable = "󰂡",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "󰅲",
}

-- From: https://github.com/VonHeikemen/lsp-zero.nvim/blob/d388e2b71834c826e61a3eba48caec53d7602510/lua/lsp-zero/cmp-mapping.lua#L221-L265
---If the completion menu is visible it will navigate to the next item in
---the list. If cursor is on top of the trigger of a snippet it'll expand
---it. If the cursor can jump to a luasnip placeholder, it moves to it.
---If the cursor is in the middle of a word that doesn't trigger a snippet
---it displays the completion menu. Else, it uses the fallback.
local function luasnip_supertab(cmp, luasnip, select_opts)
    return cmp.mapping(function(fallback)
        local col = vim.fn.col(".") - 1

        if cmp.visible() then
            cmp.select_next_item(select_opts)
        elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
        elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
            fallback()
        else
            cmp.complete()
        end
    end, { "i", "s" })
end

---If the completion menu is visible it will navigate to previous item in the
---list. If the cursor can navigate to a previous snippet placeholder, it
---moves to it. Else, it uses the fallback.
local function luasnip_shift_supertab(cmp, luasnip, select_opts)
    return cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item(select_opts)
        elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
        else
            fallback()
        end
    end, { "i", "s" })
end

return {
    {
        "nvim-cmp",
        event = "InsertEnter",
        after = function()
            local cmp = require("cmp")

            -- cmp is on the runtimepath now, so its sources can register.
            -- Taken from what is actually installed rather than a list to
            -- keep in sync: adding a cmp-* plugin in nix/module.nix and a
            -- spec below is enough.
            local sources = {}
            for name in pairs(-require("lze").state) do
                if name ~= "nvim-cmp" and name:match("^cmp[-_]") then
                    table.insert(sources, name)
                end
            end
            require("lze").trigger_load(sources)

            -- cmp-nvim-lsp registers its source from its own InsertEnter
            -- autocmd, which it only creates now, so it misses the very
            -- InsertEnter that got us here. Run it once by hand, otherwise
            -- LSP completion is missing until the second time you insert.
            pcall(vim.api.nvim_exec_autocmds, "InsertEnter", { group = "cmp_nvim_lsp" })

            local luasnip = require("luasnip")

            cmp.setup({
                enabled = function()
                    return vim.bo.buftype ~= "prompt" or require("cmp_dap").is_dap_buffer()
                end,
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },
                mapping = {
                    ["<Tab>"] = luasnip_supertab(cmp, luasnip),
                    ["<S-Tab>"] = luasnip_shift_supertab(cmp, luasnip),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),

                    ["<C-a>"] = cmp.mapping.complete(), -- Every cmp entry
                    ["<C-e>"] = cmp.mapping.abort(),

                    ["<C-j>"] = cmp.mapping.scroll_docs(4),
                    ["<C-k>"] = cmp.mapping.scroll_docs(-4),
                },
                formatting = {
                    format = function(entry, vim_item)
                        -- Kind icons
                        vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snippet]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                            emoji = "", -- No need for emoji menu identifier
                        })[entry.source.name]
                        return vim_item
                    end,
                },
                filetype = {
                    { "dap-repl" },
                    { "dapui_watches" },
                    { "dapui_hover" },
                    sources = {
                        name = "dap",
                    },
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "emoji" },
                },
                windowdocumentation = {
                    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                },
                experimental = {
                    ghost_text = false,
                },
            })
        end,
    },

    -- Sources register themselves from after/plugin with
    -- `require("cmp").register_source`, so cmp has to be on the runtimepath
    -- before they load. Neither dep_of (loads before) nor on_plugin (fires
    -- while the parent is still loading) guarantees that, so nvim-cmp's own
    -- after hook loads them once it is up.
    { "cmp-nvim-lsp", lazy = true },
    { "cmp-buffer", lazy = true },
    { "cmp-path", lazy = true },
    { "cmp-emoji", lazy = true },
    { "cmp-dap", lazy = true, on_require = "cmp_dap" },
    { "cmp_luasnip", lazy = true },

    {
        "luasnip",
        -- Needed by nvim-cmp, but also useful on its own
        dep_of = "nvim-cmp",
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
                disable_filetype = { "TelescopePrompt", "spectre_panel" },
                fast_wrap = {
                    map = "<M-e>",
                    chars = { "{", "[", "(", '"', "'" },
                    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
                    offset = 0, -- Offset from pattern match
                    end_key = "$",
                    keys = "qwertyuiopzxcvbnmasdfghjkl",
                    check_comma = true,
                    highlight = "PmenuSel",
                    highlight_grey = "LineNr",
                },
            })

            -- Hook into cmp's confirm_done; make sure cmp is up first, as both
            -- are triggered by the same InsertEnter event.
            require("lze").trigger_load("nvim-cmp")
            require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
        end,
    },
}
