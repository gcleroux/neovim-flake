{
  description = "Self-contained Neovim: plugins, lua config and tooling in one package";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    wrappers = {
      url = "github:nix-community/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      wrappers,
    }:
    let
      # x86_64-darwin is absent on purpose: nixpkgs 26.11 dropped support for it.
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # cmp-emoji ships an unfree emoji dataset; allow that one package so the
      # flake builds on a stock nixpkgs. Consumers that pass their own pkgs
      # (the install modules, the overlay) are unaffected.
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "cmp-emoji" ];
        };

      module = ./nix/module.nix;
      wrapper = (wrappers.lib.evalModule module).config;

      # One install module for every module system: it detects which one it
      # is in and installs accordingly. Exposed under each ecosystem's
      # conventional name below so the import reads right at the call site.
      installModule = wrappers.lib.getInstallModule {
        name = "neovim";
        value = module;
      };

      # Same config and plugins, no language servers and no tooling beyond
      # what the config needs to not look broken. For remote boxes.
      slim = {
        settings.withTools = false;
        settings.servers = { };
      };
    in
    {
      wrapperModules = {
        neovim = module;
        default = self.wrapperModules.neovim;
      };

      wrappers = {
        neovim = wrapper;
        default = self.wrappers.neovim;
      };

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          full = wrapper.wrap { inherit pkgs; };
          slim = wrapper.wrap [
            { inherit pkgs; }
            slim
          ];
          default = self.packages.${system}.full;
        }
      );

      overlays.default = final: _prev: {
        nvim = wrapper.wrap { pkgs = final; };
      };

      # `wrappers.neovim.enable = true;` plus any option from nix/module.nix
      nixosModules = {
        neovim = installModule;
        default = installModule;
      };
      homeModules = self.nixosModules;
      darwinModules = self.nixosModules;

      formatter = forAllSystems (system: (pkgsFor system).nixfmt);

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              lua-language-server
              stylua
              luajitPackages.luacheck
            ];
          };
        }
      );
    };
}
