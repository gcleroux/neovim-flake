local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
    return
end

local lsp_status_ok, lsp = pcall(require, "lsp-zero")
if not lsp_status_ok then
    vim.notify("Plugin lsp-zero is missing")
    return
end

-- Use share on_attach/capabilities from handlers file
local on_attach = require("lsp.handlers").on_attach
local capabilities = require("lsp.handlers").capabilities
local LSP = require("lsp.servers").LSP
local CMD = require("lsp.servers").CMD

lsp.preset({})

lsp.setup_servers(LSP.servers)

for _, server in ipairs(LSP.servers) do
    lspconfig[server].setup({
        cmd = CMD[server],
        settings = LSP[server],
        on_attach = on_attach,
        capabilities = capabilities,
    })
end

lsp.setup()
