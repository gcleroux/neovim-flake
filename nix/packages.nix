{ pkgs, ... }: rec {
  packages = with pkgs; [
    # File manager
    nnn
    git

    # Telescope tools
    ripgrep
    fd

    # Toggleterm tools
    bottom
    k9s
    lazygit

    # Debugger
    delve

    # Tools packages (Comes with a bunch of stuff)
    clang-tools
    gotools
    reftools
    ginkgo
    richgo
    gotestsum
    govulncheck
    mockgen

    # LSP packages
    docker-compose-language-service
    gopls
    lua-language-server
    marksman
    nil
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.typescript-language-server
    nodePackages.vscode-html-languageserver-bin
    nodePackages.vscode-json-languageserver-bin
    nodePackages.yaml-language-server
    python311Packages.jedi-language-server
    quick-lint-js
    taplo

    # Linters
    actionlint
    buf
    codespell
    cpplint
    dotenv-linter
    eslint_d
    golangci-lint
    hadolint
    luajitPackages.luacheck
    markdownlint-cli
    nodePackages.jsonlint
    proselint
    ruff
    shellcheck
    statix
    yamllint

    # Formatters
    cbfmt
    gofumpt
    isort
    nixfmt
    prettierd
    shfmt
    stylua
    golines
    goimports-reviser

    # Code actions
    gomodifytags
    gotests
    impl
    iferr
  ];

  packagesPath = pkgs.lib.makeBinPath packages;
}

