# neovim-flake

A self-contained Neovim: plugins, the lua config in `config/` and the external
tools it shells out to are all baked into one package. Nothing is read from
`~/.config/nvim`, so it runs the same on any machine with Nix.

```bash
nix run github:gcleroux/neovim-flake        # full: every LSP, linter, formatter
nix run github:gcleroux/neovim-flake#slim   # config + plugins only, small closure
nix profile install github:gcleroux/neovim-flake
```

## Outputs

Built with [nix-wrapper-modules]: the whole wrapper is one module in
`nix/module.nix`, so the same definition produces a package, an overlay and
install modules for NixOS, home-manager and nix-darwin.

| output | what it is |
| --- | --- |
| `packages.<system>.full` (`default`) | everything: plugins, language servers, formatters, linters, debug tooling |
| `packages.<system>.slim` | same config and plugins, no servers and no tooling beyond `bat`/`fd`/`git`/`ripgrep` — for remote boxes |
| `nixosModules.default`, `homeModules.default`, `darwinModules.default` | one module under three names: `wrappers.neovim.enable = true;` plus every option in `nix/module.nix` |
| `overlays.default` | adds `pkgs.nvim` |
| `wrapperModules.default` | the raw module, to compose into your own wrapper |
| `wrappers.neovim.wrap` | `wrap [ { inherit pkgs; } { settings.withTools = false; } ]` for a one-off variant |

### Installing it

The install module works out which module system it is in, so the options are
the same everywhere; only the file you put them in changes.

NixOS, with or without home-manager:

```nix
# configuration.nix
{
  imports = [ inputs.neovim-flake.nixosModules.default ];

  wrappers.neovim.enable = true;   # -> environment.systemPackages
  environment.variables.EDITOR = "nvim";
}
```

home-manager (nix-darwin is the same, via `darwinModules.default`):

```nix
{
  imports = [ inputs.neovim-flake.homeModules.default ];

  wrappers.neovim = {
    enable = true;                 # -> home.packages
    settings.nixd = {
      nixpkgs = ''import (builtins.getFlake "/etc/nixos").inputs.nixpkgs { }'';
      nixos = ''(builtins.getFlake "/etc/nixos").nixosConfigurations.myhost.options'';
    };
  };

  home.sessionVariables.EDITOR = "nvim";
}
```

No modules at all — it is just a package:

```nix
environment.systemPackages = [ inputs.neovim-flake.packages.${pkgs.system}.full ];
home.packages = [ inputs.neovim-flake.packages.${pkgs.system}.slim ];
```

```bash
nix profile install github:gcleroux/neovim-flake
```

Nothing is read from `~/.config/nvim` and nothing is written to a home
directory, so there is nothing for home-manager to manage either way.

### A smaller build

```nix
wrappers.neovim = {
  enable = true;
  settings.withTools = false;                        # drop formatters/linters
  settings.servers = { inherit (pkgs) gopls nixd; }; # keep just these two
};
```
## Layout

```
config/            the Neovim config; usable on its own, no Nix required
  init.lua           entry point, sourced by the wrapper
  lua/settings.lua   settings from nix, read from the generated info plugin
  lua/globals/       options, keymaps, commands, filetypes
  lua/themes/        colorschemes
  lua/specs/         lze specs: one file per area, this is the lazy loading
  lua/lsp/           diagnostics, LspAttach keymaps, per-server settings
  lua/utils/         standalone helpers
  luasnippets/       snippets shipped with the config
nix/
  module.nix         the whole wrapper: one spec per area, each carrying its
                     plugins, the binaries they call, and whether they are lazy
```

## Lazy loading

Plugins live in `pack/*/opt` and are loaded by [lze] from the specs in
`config/lua/specs/`. Triggers in use: `DeferredUIEnter` (right after the UI is
up), `InsertEnter`, `BufReadPost`, `ft`, `cmd`, `keys`, `on_require` (any
`require` of the plugin's modules) and `dep_of`.

A handful of plugins stay eager on purpose: `lze` itself, the colorscheme,
`nvim-treesitter` (highlighting has to be up before the first draw) and
`rainbow-delimiters` (it hooks `FileType` at startup).

To add a plugin: put it in the matching spec in `nix/module.nix` (`lazy = true`
puts it in `pack/*/opt`), then add its lze spec in `config/lua/specs/`. Its
name there is the plugin's directory name in the pack dir — `nvim-cmp`,
`comment.nvim`, `oil.nvim`.

[lze]: https://github.com/BirdeeHub/lze
[nix-wrapper-modules]: https://github.com/nix-community/nix-wrapper-modules

## Settings

Nix passes lua only what lua cannot work out for itself: which language
servers this build ships (`settings.servers`) and which flake nixd should
evaluate (`settings.nixd`). Everything else is plain lua in `config/`.

`config/lua/settings.lua` holds the defaults for both, so the tree in `config/`
also runs symlinked straight into `~/.config/nvim`, with no Nix.
