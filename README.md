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
| `packages.<system>.slim` | same config and plugins, no servers, no tooling beyond `bat`/`curl`/`fd`/`git`/`ripgrep` and a short list of treesitter grammars — for remote boxes |
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
  settings.grammars = [ "go" "nix" ];                # and their grammars
};
```
## Layout

```
config/            the Neovim config; usable on its own, no Nix required
  init.lua           entry point, sourced by the wrapper
  after/lsp/         per-server overrides, merged by `vim.lsp.config`; under
                     after/ so they win over nvim-lspconfig's own lsp/ files
  luasnippets/       snippets shipped with the config
  lua/gcleroux/      every module lives under this one namespace
    settings.lua       settings from nix, read from the generated info plugin
    options.lua        options and filetypes
    keymaps.lua        keymaps that do not belong to a plugin
    commands.lua       user commands
    plugins/           one file per spec in nix/module.nix; startup.lua sets
                       up the eager plugins, the rest are lze specs
    lsp.lua            diagnostics, LspAttach keymaps, `vim.lsp.enable()`
    tools/             standalone helpers behind a command
nix/
  module.nix         the whole wrapper: one spec per area, each carrying its
                     plugins, the binaries they call, and whether they are lazy
```

## Lazy loading

Plugins live in `pack/*/opt` and are loaded by [lze] from the specs in
`config/lua/gcleroux/plugins/`. Triggers in use: `DeferredUIEnter` (right after the UI is
up), `InsertEnter`, `ft`, `cmd`, `keys`, `on_require` (any
`require` of the plugin's modules) and `dep_of`.

A handful of plugins stay eager on purpose: `lze` itself, the colorscheme,
`nvim-treesitter` (highlighting has to be up before the first draw),
`rainbow-delimiters` (it hooks `FileType` at startup) and `nvim-lspconfig`
(only server definitions, read by `vim.lsp.enable()`). The servers themselves
are enabled on `DeferredUIEnter`, after the first draw.

To add a plugin: put it in a spec in `nix/module.nix` (`lazy = true` puts it in
`pack/*/opt`), then add its lze spec to the file of the same name in
`config/lua/gcleroux/plugins/`. Its name there is the plugin's directory name in the
pack dir — `blink.cmp`, `comment.nvim`, `oil.nvim`. A new spec also needs its
name added to the list in `config/lua/gcleroux/plugins/init.lua`.

Disabling a spec drops its plugins and binaries from the build, and lua skips
the matching file, so none of its keymaps or commands are left pointing at a
missing plugin. The definition needs a `data` field to be read as a spec
rather than as a plugin:

```nix
wrappers.neovim.specs.dap = { enable = false; data = [ ]; };
```

[lze]: https://github.com/BirdeeHub/lze
[nix-wrapper-modules]: https://github.com/nix-community/nix-wrapper-modules

## Settings

Nix passes lua only what lua cannot work out for itself: which specs are
enabled, which language servers this build ships (`settings.servers`) and
which flake nixd should evaluate (`settings.nixd`). Everything else is plain
lua in `config/`.

`config/lua/gcleroux/settings.lua` holds the defaults for all three, so the tree in `config/`
also runs symlinked straight into `~/.config/nvim`, with no Nix.
