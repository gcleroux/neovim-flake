-- Statusline, bufferline, file explorer and terminals.

-- Shared float geometry for the toggleterm terminals
local float_opts = {
    border = "single",
    width = function()
        return math.floor(vim.o.columns * 0.85)
    end,
    height = function()
        return math.floor(vim.o.lines * 0.85)
    end,
}

-- <leader> mapping -> command run in a floating terminal
local terminals = {
    ["<leader>gg"] = { cmd = "lazygit", dir = "git_dir", close_key = true },
    ["<leader>mm"] = { cmd = "btm", close_key = true },
    ["<leader>kk"] = { cmd = "k9s" },
}

local terminal_keys = {}
for lhs in pairs(terminals) do
    table.insert(terminal_keys, { lhs, mode = "n" })
end
table.insert(terminal_keys, { "<c-t>", mode = { "n", "i", "t" } })

return {
    {
        "bufferline.nvim",
        event = "DeferredUIEnter",
        after = function()
            require("bufferline").setup({
                options = {
                    numbers = "none",
                    close_command = false,
                    right_mouse_command = false,
                    left_mouse_command = false,
                    middle_mouse_command = nil,
                    -- NOTE: this plugin is designed with this icon in mind,
                    -- and so changing this is NOT recommended
                    indicator = { style = "icon", icon = "▎" },
                    buffer_close_icon = "",
                    modified_icon = "●",
                    close_icon = "",
                    left_trunc_marker = "",
                    right_trunc_marker = "",
                    max_name_length = 30,
                    max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
                    tab_size = 21,
                    diagnostics = "nvim_lsp",
                    diagnostics_update_in_insert = false,
                    diagnostics_indicator = function(count, level, _, _)
                        local icon = level:match("error") and " " or " "
                        return " " .. icon .. count
                    end,
                    offsets = {
                        { filetype = "nnn", text = "File Explorer", highlight = "Directory", separator = true },
                    },
                    show_buffer_icons = true,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    show_tab_indicators = true,
                    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
                    separator_style = "thin",
                    enforce_regular_tabs = true,
                    always_show_bufferline = true,
                },
            })
        end,
    },

    {
        "lualine.nvim",
        event = "DeferredUIEnter",
        after = function()
            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = "auto",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                    always_divide_middle = true,
                    globalstatus = false,
                    refresh = {
                        statusline = 1000,
                        tabline = 1000,
                        winbar = 1000,
                    },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { "filename" },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                tabline = {},
                winbar = {},
                inactive_winbar = {},
                extensions = {},
            })
        end,
    },

    {
        "oil.nvim",
        cmd = "Oil",
        on_require = "oil",
        keys = {
            { "<tab>", "<cmd>Oil<cr>", desc = "Open parent directory" },
        },
        after = function()
            require("oil").setup({
                default_file_explorer = true,
                columns = { "icon" },

                -- Window-local options to use for oil buffers
                win_options = {
                    wrap = false,
                    signcolumn = "yes",
                    cursorcolumn = false,
                    foldcolumn = "0",
                    spell = false,
                    list = false,
                    conceallevel = 3,
                    concealcursor = "nvic",
                },
                skip_confirm_for_simple_edits = true,
                keymaps = {
                    ["g?"] = "actions.show_help",
                    ["<CR>"] = "actions.select",
                    ["<BS>"] = "actions.parent",
                    ["<C-s>"] = {
                        "actions.select",
                        opts = { vertical = true },
                        desc = "Open the entry in a vertical split",
                    },
                    ["<C-h>"] = {
                        "actions.select",
                        opts = { horizontal = true },
                        desc = "Open the entry in a horizontal split",
                    },
                    ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
                    ["<C-p>"] = "actions.preview",
                    ["<C-c>"] = "actions.close",
                    ["<C-l>"] = "actions.refresh",
                    ["-"] = "actions.parent",
                    ["_"] = "actions.open_cwd",
                    ["`"] = "actions.cd",
                    ["~"] = {
                        "actions.cd",
                        opts = { scope = "tab" },
                        desc = ":tcd to the current oil directory",
                        mode = "n",
                    },
                    ["gs"] = "actions.change_sort",
                    ["gx"] = "actions.open_external",
                    ["g."] = "actions.toggle_hidden",
                    ["g\\"] = "actions.toggle_trash",
                },
                -- Configuration for the floating window in oil.open_float
                float = {
                    -- preview_split: Split direction: "auto", "left", "right", "above", "below".
                    preview_split = "right",
                },
            })
        end,
    },

    {
        "toggleterm.nvim",
        cmd = { "ToggleTerm", "TermExec" },
        keys = terminal_keys,
        after = function()
            require("toggleterm").setup({
                open_mapping = [[<c-t>]],
                direction = "float",
                float_opts = float_opts,
            })

            local Terminal = require("toggleterm.terminal").Terminal

            for lhs, spec in pairs(terminals) do
                local term = Terminal:new({
                    cmd = spec.cmd,
                    dir = spec.dir,
                    direction = "float",
                    float_opts = float_opts,
                    on_open = function(term)
                        vim.cmd("startinsert!")
                        if spec.close_key then
                            vim.api.nvim_buf_set_keymap(
                                term.bufnr,
                                "n",
                                "q",
                                "<cmd>close<CR>",
                                { noremap = true, silent = true }
                            )
                        end
                    end,
                    on_close = function()
                        vim.cmd("startinsert!")
                    end,
                })

                vim.keymap.set("n", lhs, function()
                    term:toggle()
                end, { noremap = true, silent = true, desc = spec.cmd })
            end
        end,
    },
}
