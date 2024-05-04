local conform_status_ok, conform = pcall(require, "conform")
if not conform_status_ok then
    vim.notify("Plugin conform is missing")
    return
end

conform.setup({
    formatters = {
        clang_format = {
            prepend_args = { "-style", "google" },
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
        go = { "gimports-reviser", "gofumpt", "golines" },
        html = { "prettierd" },
        javascript = { "prettierd" },
        json = { "prettierd" },
        lua = { "stylua" },
        markdown = { "markdownlint", "prettierd" },
        nix = { "nixfmt" },
        proto = { "buf" },
        python = { "ruff_fix", "ruff_format", "isort" },
        sh = { "shfmt" },
        typescript = { "prettierd" },
        yaml = { "prettierd" },
    },
    format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
    },
})
