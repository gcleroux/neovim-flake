-- The two things the lua config cannot work out for itself.
--
-- The wrapper generates an info plugin holding whatever the nix module put in
-- its `info` option; `vim.g.nix_info_plugin_name` is its name. Without nix
-- (config/ symlinked into ~/.config/nvim) the defaults below apply, so the
-- config still runs on its own.

local defaults = {
    lsp = {
        -- Servers to `vim.lsp.enable()`. Comes from nix because only the
        -- build knows which language server binaries it actually ships.
        servers = {},
    },

    -- Expressions for `lua/lsp/servers/nixd.lua`: which flake to evaluate for
    -- NixOS and home-manager option completion. Deployment specific.
    ---@type { nixpkgs: string?, nixos: string?, home_manager: string? }?
    nixd = nil,
}

local function from_nix()
    local name = vim.g.nix_info_plugin_name
    if not name then
        return {}
    end
    local ok, info = pcall(require, name)
    if not ok then
        return {}
    end
    return info({}, "info", "nvim")
end

return vim.tbl_deep_extend("force", defaults, from_nix())
