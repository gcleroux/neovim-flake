{
  description = "My personal neovim config";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        inherit (import ./nix { inherit pkgs; }) plugins packagesPath;

        initFile = pkgs.writeTextFile {
          name = "init.lua";
          text = ''
            vim.loader.enable()
            vim.opt.rtp:append("${./nvim}")
            vim.g.plugin_config_dir = "${./nvim/lua}"

            -- Setup global config
            require("globals")

            -- Plugins config
            require("plugins")

            -- Set up the colorscheme (comes before ui)
            require("themes.nordfox")

            -- Set up the UI
            require("ui")

            -- Debuggers config
            require("debuggers")

            -- Set up LSP (Should be loaded last)
            require("lsp")
          '';
        };

        neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
          customRC = "luafile ${initFile}";
        } // {
          viAlias = true;
          vimAlias = true;
          withNodeJs = false;
          withPython3 = false;
          withRuby = false;
          packpathDirs.myNeovimPackages.start = plugins;
          wrapperArgs = pkgs.lib.escapeShellArgs [
            "--suffix"
            "PATH"
            ":"
            "${packagesPath}"
          ];
        };
      in rec {
        packages.neovim-flake =
          pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig;
        packages.default = packages.neovim-flake;

        apps.neovim-flake = inputs.flake-utils.lib.mkApp {
          drv = packages.neovim-flake;
          name = "neovim-flake";
          exePath = "/bin/nvim";
        };
        apps.default = apps.neovim-flake;

        devShell =
          pkgs.mkShell { buildInputs = [ packages.neovim-flake pkgs.just ]; };
      });
}
