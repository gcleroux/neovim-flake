local go_status_ok, go = pcall(require, "go")
if not go_status_ok then
    vim.notify("Plugin go is missing")
    return
end

go.setup({
    go = "go",
    -- goimport = "goimports-reviser",
    -- fillstruct = "fillstruct",
    -- gofmt = "golines",
    -- gopls_remote_auto = false,
    -- max_line_len = 100,
    -- tag_options = "json=omitempty",
    trouble = true,

    lsp_document_formatting = false,
    lsp_keymaps = false,
    lsp_codelens = false,
    diagnostic = false,
    lsp_inlay_hints = {
        enable = false,
    },
    textobjects = false,

    dap_debug = true,
    dap_debug_gui = true,
    dap_debug_vt = true,
    dap_debug_keymap = false,
    dap_port = 38697,
    dap_timeout = 15,
    dap_retries = 20,
    icons = false,

    test_runner = "gotestsum",
    gocoverage_sign = "█",
    verbose_tests = true,
    iferr_vertical_shift = 4,
})
