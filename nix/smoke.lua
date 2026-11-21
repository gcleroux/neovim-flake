-- Smoke test run by `nix flake check` against each built package. Sourced with
-- --cmd so the notify hook is in place before the config loads, then
-- `_G.smoke()` runs from -c once startup is done. Exits non-zero on failure.

local notes = {}
local notify = vim.notify
vim.notify = function(msg, level, opts)
    if (level or vim.log.levels.INFO) >= vim.log.levels.WARN then
        table.insert(notes, msg)
    end
    return notify(msg, level, opts)
end

local function checks(fail, report)
    vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter", modeline = false })

    local lze = require("lze")
    local pending = {}
    for name, state in pairs(-lze.state) do
        if state then
            table.insert(pending, name)
        end
    end
    lze.trigger_load(pending)
    -- Plugin setup that finishes asynchronously reports its errors later.
    vim.wait(1000)
    for name, state in pairs(-lze.state) do
        if state then
            fail("plugin not loaded: " .. name)
        end
    end
    report(#pending .. " lazy plugins loaded")

    local servers = require("gcleroux.settings").lsp.servers
    for _, name in ipairs(servers) do
        local ok, config = pcall(function()
            return vim.lsp.config[name]
        end)
        if not ok or not config then
            fail("lsp config " .. name .. ": " .. tostring(config))
        elseif type(config.cmd) == "table" and vim.fn.executable(config.cmd[1]) == 0 then
            fail("lsp server " .. name .. ": " .. config.cmd[1] .. " not on PATH")
        end
    end
    report(#servers .. " language servers on PATH")

    local langs = {}
    for _, parser in ipairs(vim.api.nvim_get_runtime_file("parser/*.so", true)) do
        langs[vim.fn.fnamemodify(parser, ":t:r")] = true
    end
    for lang in pairs(langs) do
        local ok, err = pcall(vim.treesitter.query.get, lang, "highlights")
        if not ok then
            fail("treesitter " .. lang .. ": " .. err)
        end
    end
    report(vim.tbl_count(langs) .. " treesitter parsers with their highlight queries")

    if os.getenv("SMOKE_TOOLS") then
        local conform = require("conform")
        local names = {}
        for _, formatters in pairs(conform.formatters_by_ft) do
            for _, name in ipairs(formatters) do
                names[name] = true
            end
        end
        for name in pairs(names) do
            local info = conform.get_formatter_info(name)
            if not info.available then
                fail("formatter " .. name .. ": " .. info.available_msg)
            end
        end
        report(vim.tbl_count(names) .. " formatters available")
    end

    if vim.g.colors_name ~= "nordfox" then
        fail("colorscheme not loaded")
    end
end

_G.smoke = function()
    local failures, lines = {}, {}
    local function fail(msg)
        table.insert(failures, msg)
    end
    local function report(msg)
        table.insert(lines, "ok: " .. msg)
    end

    local ok, err = xpcall(checks, debug.traceback, fail, report)
    if not ok then
        fail("smoke test error: " .. err)
    end
    for _, msg in ipairs(notes) do
        fail("notification: " .. msg)
    end
    for line in vim.api.nvim_exec2("messages", { output = true }).output:gmatch("[^\n]+") do
        if line:match("^E%d+:") or line:match("Error") then
            fail("message: " .. line)
        end
    end

    for _, msg in ipairs(failures) do
        table.insert(lines, "FAIL: " .. msg)
    end
    io.stdout:write("\n" .. table.concat(lines, "\n") .. "\n")
    vim.cmd(#failures == 0 and "qa!" or "cquit 1")
end
