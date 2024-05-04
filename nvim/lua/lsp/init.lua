-- Set up handlers
-- require("lsp.handlers").setup()

-- Formatters and linters
-- require("lsp.null-ls") -- Must be loaded after mason-null-ls
require("lsp.nvim-lint")
require("lsp.conform")
require("lsp.code-actions")
-- TODO: Add hover

-- Specific go plugin
require("lsp.go")

require("lsp.lsp-zero")
-- LSP config
-- require("lsp.lspconfig") -- Always load lspconfig at the end
