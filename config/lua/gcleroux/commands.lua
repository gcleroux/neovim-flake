vim.api.nvim_create_user_command("W", "noautocmd w", {})

vim.api.nvim_create_user_command("InsertCRDSchema", function()
    require("gcleroux.tools.crd_schemas").insert_modeline()
end, {})
