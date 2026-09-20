# The whole wrapper: plugins, the tools they shell out to, and the lua config
# directory, as one nix-wrapper-modules module.
#
# Each spec below mirrors a file in config/lua/specs/: the plugins, the
# binaries they call and whether they are lazy all live in one place. `lazy`
# puts a plugin in pack/myNeovimPackages/opt, which is what lze packadds.
{
  config,
  options,
  lib,
  pkgs,
  wlib,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.settings;
in
{
  imports = [ wlib.wrapperModules.neovim ];

  options.settings = {
    withTools = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Ship the formatters, linters and other binaries the plugins call.
        Turning this off leaves the config and its plugins intact, with a much
        smaller closure.
      '';
    };

    servers = mkOption {
      type = types.attrsOf types.package;
      default = {
        bashls = pkgs.bash-language-server;
        clangd = pkgs.clang-tools;
        docker_compose_language_service = pkgs.docker-compose-language-service;
        dockerls = pkgs.dockerfile-language-server;
        gopls = pkgs.gopls;
        html = pkgs.vscode-langservers-extracted;
        jedi_language_server = pkgs.python313Packages.jedi-language-server;
        jsonls = pkgs.vscode-langservers-extracted;
        lua_ls = pkgs.lua-language-server;
        marksman = pkgs.marksman;
        nixd = pkgs.nixd;
        taplo = pkgs.taplo;
        ts_ls = pkgs.typescript-language-server;
        yamlls = pkgs.yaml-language-server;
      };
      description = ''
        Language servers to ship and enable, keyed by lspconfig name. The keys
        are what lua calls `vim.lsp.enable()` with, so a build never enables a
        server whose binary it does not ship. `{ }` disables LSP.
      '';
    };

    nixd = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        nixpkgs = ''import (builtins.getFlake "/etc/nixos").inputs.nixpkgs { }'';
      };
      description = ''
        Expressions for nixd: `nixpkgs`, `nixos` and `home_manager`. Which
        flake to evaluate is deployment specific, so it is left unset here.
      '';
    };
  };

  # The only things lua cannot work out for itself: which servers this build
  # ships, and which flake nixd should evaluate.
  config.info.nvim = {
    inherit (cfg) nixd;
    lsp.servers = lib.attrNames cfg.servers;
  };

  # No language providers; nothing in the config uses them and each one drags
  # in a whole interpreter.
  config.hosts.node.nvim-host.enable = false;
  config.hosts.python3.nvim-host.enable = false;
  config.hosts.ruby.nvim-host.enable = false;

  # mkDefault so a consumer can override it, e.g. point it at a working tree
  # with `mkLuaInline "vim.fn.stdpath('config')"` for live lua edits.
  config.settings.config_directory = lib.mkDefault ../config;
  config.settings.aliases = [
    "vi"
    "vim"
  ];

  config.specs = {
    # Not lazy: the loader, highlighting (must be up before the first draw),
    # rainbow-delimiters (hooks FileType at startup) and the colorscheme.
    startup = {
      lazy = false;
      data = with pkgs.vimPlugins; [
        lze
        nvim-treesitter.withAllGrammars
        rainbow-delimiters-nvim
        nightfox-nvim
      ];
    };

    # Pulled in by lze's on_require / dep_of handlers
    deps = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        plenary-nvim
        nvim-web-devicons
        SchemaStore-nvim
        bufdelete-nvim
      ];
    };

    completion = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-emoji
        cmp-dap
        cmp_luasnip
        luasnip
        friendly-snippets
        nvim-autopairs
      ];
    };

    editing = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        comment-nvim
        nvim-surround
        neogen
        nvim-treesitter-textobjects
        vim-suda
      ];
    };

    ui = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        bufferline-nvim
        lualine-nvim
        oil-nvim
        toggleterm-nvim
      ];
      # The floating terminals bound to <leader>gg / mm / kk
      runtimePkgs = with pkgs; [
        bottom
        k9s
        lazygit
      ];
    };

    finder = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        fzf-lua
        nvim-neoclip-lua
      ];
    };

    git = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        gitsigns-nvim
      ];
    };

    lsp = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-lspconfig
        conform-nvim
        nvim-lint
      ];
      runtimePkgs = with pkgs; [
        # Formatters
        cbfmt
        gofumpt
        goimports-reviser
        gotools # goimports
        isort
        markdownlint-cli
        nixfmt
        prettierd
        ruff
        shfmt
        stylua

        # Linters
        actionlint
        biome
        buf
        codespell
        cppcheck
        dotenv-linter
        golangci-lint
        hadolint
        luajitPackages.luacheck
        proselint
        shellcheck
        statix
        yamllint

        # Runtime some of them need
        nodejs-slim
      ];
    };

    dap = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
      ];
      runtimePkgs = [ pkgs.delve ];
    };

    markdown = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        render-markdown-nvim
        vim-markdown-toc
      ];
    };
  };

  # Lets a spec carry the binaries its plugins call.
  # From the neovim module's tips and tricks section.
  config.specMods =
    { ... }:
    {
      options.runtimePkgs = options.runtimePkgs // {
        description = ''
          Packages to put on neovim's PATH. Dropped when the spec is disabled.
        '';
      };
    };

  config.runtimePkgs =
    # Without these the config is visibly broken, so they are never dropped
    (with pkgs; [
      bat # fzf-lua previewer
      fd # fzf-lua file finder
      gitMinimal # gitsigns, the lazygit terminal
      ripgrep # fzf-lua live grep
    ])
    ++ lib.attrValues cfg.servers
    ++ lib.optionals cfg.withTools (config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ]);
}
