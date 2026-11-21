local settings = require("gcleroux.settings")

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "»",
        },
    },
    update_in_insert = true,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "single",
        source = true,
        header = "",
        prefix = "",
        suffix = "",
    },
})

-- `gr` is mapped to references below; any default gr* mapping would make it
-- wait for 'timeoutlen'.
for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
    if m.lhs:match("^gr.") then
        vim.keymap.del("n", m.lhs)
    end
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("gcleroux_lsp", { clear = true }),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client then
            client.server_capabilities.semanticTokensProvider = nil
        end

        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
        end

        map("n", "gd", "<cmd>FzfLua lsp_definitions<CR>", "Go to definition")
        map("n", "gi", "<cmd>FzfLua lsp_implementations<CR>", "Go to implementation")
        map("n", "gr", "<cmd>FzfLua lsp_references<CR>", "List references")
        map({ "n", "v" }, "<leader>ca", "<cmd>FzfLua lsp_code_actions<CR>", "Code actions")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gs", vim.lsp.buf.signature_help, "Signature help")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("n", "gl", vim.diagnostic.open_float, "Show line diagnostics")
        map("n", "[d", function()
            vim.diagnostic.jump({ count = -1, float = true })
        end, "Previous diagnostic")
        map("n", "]d", function()
            vim.diagnostic.jump({ count = 1, float = true })
        end, "Next diagnostic")
    end,
})

vim.lsp.enable(settings.lsp.servers)
