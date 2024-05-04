local o = vim.o
-- local wo = vim.wo
-- local bo = vim.bo

-- Set the leader key to spacebar
vim.g.mapleader = " "

-- Global options
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
o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
o.foldlevelstart = 99 -- Starting at foldlevel 99 makes all code visible (unfolded)
o.foldenable = true

-- Window local options

-- Buffer local options
