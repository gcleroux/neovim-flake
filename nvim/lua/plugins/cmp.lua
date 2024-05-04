local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
    return
end

local luasnip_status_ok, luasnip = pcall(require, "luasnip")
if not luasnip_status_ok then
    vim.notify("Plugin luasnip is missing")
    return
end

local lsp_zero_status_ok, lsp_zero = pcall(require, "lsp-zero")
if not lsp_zero_status_ok then
    vim.notify("Plugin lsp-zero is missing")
    return
end

local kind_icons = {
    Text = "",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰇽",
    Variable = "󰂡",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "󰅲",
}

cmp.setup({
    enabled = function()
        return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
    end,
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    mapping = {
        ["<Tab>"] = lsp_zero.cmp_action().luasnip_supertab(),
        ["<S-Tab>"] = lsp_zero.cmp_action().luasnip_shift_supertab(),
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
