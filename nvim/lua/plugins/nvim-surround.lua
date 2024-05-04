local cmp_status_ok, surround = pcall(require, "nvim-surround")
if not cmp_status_ok then
    return
end

surround.setup({
    -- Empty for default config
})
