vim.cmd.colorscheme("nordfox")

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("gcleroux_treesitter", { clear = true }),
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)

        if vim.bo[args.buf].filetype ~= "yaml" then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})
