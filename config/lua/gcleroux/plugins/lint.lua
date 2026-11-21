return {
    {
        "nvim-lint",
        event = "DeferredUIEnter",
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
