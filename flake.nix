{
  description = "System configuration";


  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-bcachefs.url = "github:YellowOnion/nixpkgs/bcachefs-fix";
  };


  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:

    let

      hostsConfigs = (
        dir: builtins.listToAttrs (
          map (host: {
            name = host;
            value = dir + "/${host}/configuration.nix";
          }) (builtins.attrNames (builtins.readDir dir)))
      ) ./hosts;

      nixosModules = (
        dir: map (mod: dir + "/${mod}")
          (builtins.attrNames (builtins.readDir dir))
      ) ./lib/modules;

      unstable-overlay = final: prev: {  # TODO: define these on ./lib/overlays
        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;
          config.allowUnfree = true;
        };
      };
      overlayModules = [
        ({ ... }: { nixpkgs.overlays = [ unstable-overlay ]; })
      ];

      mkHost = hostConfig:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = overlayModules ++ nixosModules ++ [
            hostConfig
            "${inputs.nixpkgs-bcachefs}/nixos/modules/tasks/filesystems/bcachefs.nix"
          ];
        };

    in {
      nixosConfigurations = builtins.mapAttrs
        (host: config: mkHost config) hostsConfigs;
    };
}
