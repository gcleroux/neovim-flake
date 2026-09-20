-- Anything that needs a real file open: language servers, formatters,
-- linters. `vim.lsp.enable()` re-runs the FileType autocmds for buffers that
-- are already open, so attaching from BufReadPost is not too late.

-- Loading a plugin from inside a BufReadPost autocmd stops neovim's own
-- filetype detection from running for that buffer: the file opens with no
-- filetype, so no treesitter and no LSP. Only the first file is affected,
-- since after that these are loaded and the trigger is gone. Load them once
-- the UI is up instead; vim.lsp.enable re-runs FileType for open buffers.
local load_event = "DeferredUIEnter"

return {
    {
        "nvim-lspconfig",
        event = load_event,
        after = function()
            -- Diagnostics, LspAttach keymaps and `vim.lsp.enable()` per server
            require("lsp")
        end,
    },

    {
        "conform.nvim",
        event = load_event,
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
        end,
    },

    {
        "nvim-lint",
        event = load_event,
        after = function()
            local lint = require("lint")

            local linters_by_ft = {
                c = { "clangtidy", "cppcheck" },
                cpp = { "clangtidy", "cppcheck" },
                dockerfile = { "hadolint" },
                go = { "golangcilint" },
                javascript = { "biomejs" },
                json = { "biomejs" },
                lua = { "luacheck" },
                markdown = { "markdownlint", "proselint" },
                nix = { "statix" },
                proto = { "buf_lint" },
                python = { "ruff" },
                sh = { "shellcheck" },
                env = { "dotenv_linter" },
                typescript = { "biomejs" },
                -- yaml = { "yamllint", "actionlint" },
            }

            -- use for codespell for all except bib and css
            for ft, _ in pairs(linters_by_ft) do
                if ft ~= "bib" and ft ~= "css" then
                    table.insert(linters_by_ft[ft], "codespell")
                end
            end

            -- Keep only the linters whose binary is on PATH. A build without
            -- the tooling (`withTools = false`) ships none of them, and
            -- nvim-lint raises an error per buffer for every missing one.
            local function available(name)
                local ok, linter = pcall(require, "lint.linters." .. name)
                if not ok or type(linter) ~= "table" then
                    return false
                end
                local cmd = linter.cmd
                if type(cmd) == "function" then
                    local resolved
                    ok, resolved = pcall(cmd)
                    cmd = ok and resolved or nil
                end
                return type(cmd) == "string" and vim.fn.executable(cmd) == 1
            end

            lint.linters_by_ft = {}
            for ft, linters in pairs(linters_by_ft) do
                local usable = vim.tbl_filter(available, linters)
                if #usable > 0 then
                    lint.linters_by_ft[ft] = usable
                end
            end

            -- Trigger linter automatically
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
                callback = function()
                    pcall(lint.try_lint)
                end,
            })

            -- The event that loaded us already fired for this buffer
            pcall(lint.try_lint)
        end,
    },
}
