-- nixd needs to know which flake to evaluate for completion of NixOS and
-- home-manager options. That is deployment-specific, so it comes from
-- `settings.nixd` (set by the consumer, see nix/module.nix).
local settings = require("settings")
local nixd = settings.nixd

if not nixd or not next(nixd) then
    return {}
end

local expr = function(value)
    return value and { expr = value } or nil
end

return {
    settings = {
        nixd = {
            nixpkgs = expr(nixd.nixpkgs),
            options = {
                nixos = expr(nixd.nixos),
                home_manager = expr(nixd.home_manager),
            },
        },
    },
}
