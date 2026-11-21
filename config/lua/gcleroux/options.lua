local o = vim.o

vim.g.mapleader = " "

o.relativenumber = true
o.clipboard = ""
o.fileencoding = "utf-8"
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.scrolloff = 6
o.mouse = "nv"
o.smartindent = true
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.number = true
o.numberwidth = 4
o.cursorline = true
o.termguicolors = true
o.showmode = false
o.foldcolumn = "0"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true

vim.filetype.add({
    filename = {
        [".env"] = "env",
    },
})
vim.treesitter.language.register("bash", "env")
