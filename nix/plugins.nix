{ pkgs, ... }:
{
  plugins = with pkgs.vimPlugins; [
    # LSP plugins
    go-nvim
    lsp-zero-nvim
    # null-ls-nvim
    nvim-lint
    conform-nvim
    actions-preview-nvim
    nvim-lspconfig

    # CMP plugins
    cmp-buffer
    cmp-cmdline
    cmp-dap
    cmp-emoji
    cmp-nvim-lsp
    cmp-path
    cmp_luasnip
    friendly-snippets
    luasnip
    nvim-cmp

    # Debugging plugins
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text

    # Utils plugins
    SchemaStore-nvim
    comment-nvim
    flash-nvim
    neogen
    nvim-autopairs
    nvim-cursorline
    nvim-surround
    nvim-ufo
    nvim-web-devicons
    plenary-nvim
    popup-nvim
    rainbow-delimiters-nvim
    suda-vim
    tmux-nvim
    vim-bbye
    vim-markdown-toc

    # Themes plugins
    nightfox-nvim
    onenord-nvim

    # UI plugins
    ChatGPT-nvim
    toggleterm-nvim
    # FTerm-nvim
    bufferline-nvim
    gitsigns-nvim
    # lazygit-nvim
    lualine-nvim
    markdown-preview-nvim
    nnn-vim
    octo-nvim
    trouble-nvim

    # Telescope plugins
    nvim-neoclip-lua
    telescope-media-files-nvim
    telescope-nvim
    fzf-lua

    # TreeSitter plugins
    nvim-treesitter.withAllGrammars
    nvim-treesitter-textobjects
  ];
}
