-- LSP setup.
--
-- Which servers are enabled is decided at build time (nix/servers.nix), so a
-- build without a given language server never tries to start it. Servers that
-- need more than the lspconfig defaults get a `lua/lsp/servers/<name>.lua`
-- returning a config table.

local settings = require("settings")

-- Diagnostics
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
    underline = true,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "single",
        source = "always",
        header = "",
        prefix = "",
        suffix = "",
    },
})

-- Disable default keybinds
for _, bind in ipairs({ "grn", "gra", "gri", "grr", "grt" }) do
    pcall(vim.keymap.del, "n", bind)
end

-- Create keybindings, commands, inlay hints and autocommands on LSP attach
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
            return
        end
        if client.server_capabilities.completionProvider then
            vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
        end
        if client.server_capabilities.definitionProvider then
            vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
        end

        --- Disable semantic tokens
        client.server_capabilities.semanticTokensProvider = nil

        -- All the keymaps
        -- stylua: ignore start
        local opts = { buffer = bufnr, remap = false, silent = true }

        vim.keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions<CR>", opts)
        vim.keymap.set("n", "gi", "<cmd>FzfLua lsp_implementations<CR>", opts)
        vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references<CR>", opts)
        vim.keymap.set({ "n", "v" }, "<leader>ca", "<cmd>FzfLua lsp_code_actions<CR>", opts)

        vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
        vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
        vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
        vim.keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
        vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
        vim.keymap.set("n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
        vim.keymap.set("n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
        -- stylua: ignore end
    end,
})

-- Per-server overrides, when the file exists
local function server_config(name)
    local mod = "lsp.servers." .. name
    if #vim.api.nvim_get_runtime_file("lua/" .. mod:gsub("%.", "/") .. ".lua", false) == 0 then
        return nil
    end
    return require(mod)
end

for _, name in ipairs(settings.lsp.servers) do
    local config = server_config(name)
    if config then
        vim.lsp.config(name, config)
    end
    vim.lsp.enable(name)
end
