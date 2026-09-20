-- nvim-treesitter ships the parsers through Nix and is loaded eagerly, so
-- highlighting is up before the first buffer is drawn.
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local bufnr = args.buf
        local ft = vim.bo[bufnr].filetype

        pcall(vim.treesitter.start, bufnr)

        if ft ~= "yaml" then
            vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})
