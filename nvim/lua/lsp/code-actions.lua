local actions_status_ok, actions = pcall(require, "actions-preview")
if not actions_status_ok then
    vim.notify("Plugin actions-preview is missing")
    return
end

actions.setup({
    telescope = {
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
            width = 0.8,
            height = 0.9,
            prompt_position = "top",
            preview_cutoff = 20,
            preview_height = function(_, _, max_lines)
                return max_lines - 15
            end,
        },
    },
})

vim.keymap.set({ "v", "n" }, "<leader>ca", actions.code_actions)
