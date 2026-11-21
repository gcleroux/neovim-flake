local o = vim.o

vim.g.mapleader = " "

o.number = true
o.relativenumber = true
o.cursorline = true
o.showmode = false
o.termguicolors = true
o.scrolloff = 6
o.mouse = "nv"
o.ignorecase = true
o.expandtab = true
o.smartindent = true
o.shiftwidth = 4
o.tabstop = 4
o.foldlevel = 99
o.foldlevelstart = 99

vim.filetype.add({
    filename = {
        [".env"] = "env",
    },
})
vim.treesitter.language.register("bash", "env")
