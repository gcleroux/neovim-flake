return {
    {
        "conform.nvim",
        event = "DeferredUIEnter",
        cmd = "ConformInfo",
        on_require = "conform",
        after = function()
            require("conform").setup({
                formatters = {
                    clang_format = {
                        prepend_args = { "-style", "google" },
                    },
                    goimports = {
                        stdin = false,
                        args = { "-w", "-srcdir", "$DIRNAME", "$FILENAME" },
                    },
                    ["goimports-reviser"] = {
                        prepend_args = { "-rm-unused", "-set-alias" },
                    },
                },
                formatters_by_ft = {
                    c = { "clang_format" },
                    cpp = { "clang_format" },
                    css = { "prettierd" },
                    cuda = { "clang_format" },
                    -- Must remove unused imports before adding missing ones
                    go = { "goimports-reviser", "goimports", "gofumpt" },
                    html = { "prettierd" },
                    javascript = { "prettierd" },
                    json = { "prettierd" },
                    lua = { "stylua" },
                    markdown = { "markdownlint", "prettierd" },
                    nix = { "nixfmt" },
                    proto = { "buf" },
                    python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
                    sh = { "shfmt" },
                    typescript = { "prettierd" },
                    yaml = { "prettierd" },
                },
                format_on_save = {
                    timeout_ms = 1000,
                    lsp_fallback = true,
                },
            })
        end,
    },
}
