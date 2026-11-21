-- Debugging.
--
-- An adapter whose command is not on PATH is not registered, so a build
-- without the debugger binaries simply has no configurations for it.

local function executable(cmd)
    return cmd ~= nil and vim.fn.executable(cmd) == 1
end

local function configure_python(dap)
    local command = os.getenv("HOME") .. "/.virtualenvs/debugpy/bin/python"
    if not executable(command) then
        return
    end

    dap.adapters.python = {
        type = "executable",
        command = command,
        args = { "-m", "debugpy.adapter" },
    }

    dap.configurations.python = {
        {
            -- The first three options are required by nvim-dap
            type = "python", -- established the link to `dap.adapters.python`
            request = "launch",
            name = "Launch file",

            -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
            program = "${file}", -- launch the current file
            pythonPath = function()
                -- debugpy supports launching an application with a different
                -- interpreter than the one used to launch debugpy itself.
                local cwd = vim.fn.getcwd()
                if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                    return cwd .. "/venv/bin/python"
                elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                    return cwd .. "/.venv/bin/python"
                else
                    return vim.fn.exepath("python3")
                end
            end,
        },
    }
end

local function configure_go(dap)
    local command = "dlv"
    if not executable(command) then
        return
    end

    dap.adapters.go = {
        type = "server",
        port = "${port}",
        executable = {
            command = command,
            args = { "dap", "-l", "127.0.0.1:${port}" },
        },
    }

    dap.configurations.go = {
        {
            type = "go",
            name = "Debug file",
            request = "launch",
            program = "${file}",
        },
        {
            type = "go",
            name = "Debug test (file)",
            request = "launch",
            mode = "test",
            program = "${file}",
        },
        {
            type = "go",
            name = "Debug test (package)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}",
        },
    }
end

local keys = {
    {
        "<F5>",
        function()
            require("dap").continue()
        end,
        desc = "Debug: continue",
    },
    {
        "<F10>",
        function()
            require("dap").step_over()
        end,
        desc = "Debug: step over",
    },
    {
        "<F11>",
        function()
            require("dap").step_into()
        end,
        desc = "Debug: step into",
    },
    {
        "<F12>",
        function()
            require("dap").step_out()
        end,
        desc = "Debug: step out",
    },
    {
        "<leader>b",
        function()
            require("dap").toggle_breakpoint()
        end,
        desc = "Debug: toggle breakpoint",
    },
    {
        "<leader>B",
        function()
            require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Debug: conditional breakpoint",
    },
    {
        "<leader>lp",
        function()
            require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end,
        desc = "Debug: log point",
    },
    {
        "<leader>dbg",
        function()
            require("dap").repl.open()
        end,
        desc = "Debug: open REPL",
    },
    {
        "<leader>rl",
        function()
            require("dap").run_last()
        end,
        desc = "Debug: run last",
    },
}

return {
    {
        "nvim-dap",
        on_require = "dap",
        keys = keys,
        after = function()
            local dap = require("dap")

            configure_python(dap)
            configure_go(dap)

            -- go.nvim used to set these two up through its dap_debug_gui and
            -- dap_debug_vt options; with it gone they are wired here.
            local dapui = require("dapui")
            dapui.setup()
            require("nvim-dap-virtual-text").setup({})

            dap.listeners.after.event_initialized["dapui"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui"] = function()
                dapui.close()
            end
        end,
    },

    -- Set up by the nvim-dap spec above; they only need to be on the
    -- runtimepath before it runs.
    { "nvim-dap-ui", dep_of = "nvim-dap", on_require = "dapui" },
    { "nvim-dap-virtual-text", dep_of = "nvim-dap" },
}
