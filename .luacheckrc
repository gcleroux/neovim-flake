ignore = {
    "122", -- Setting a read-only field of a global variable.
    "631", -- max_line_length, URL are too long
}

-- Global objects defined by the C code
read_globals = {
    "vim",
}
