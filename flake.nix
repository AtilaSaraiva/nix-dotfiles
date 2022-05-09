{
  description = "System configuration";


  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-2111.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-2105.url = "github:NixOS/nixpkgs/nixos-21.05";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
  };


  outputs = { self, nixpkgs, ... }@inputs:

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

      unstable-small-overlay = final: prev: {  # TODO: define these on ./lib/overlays
        unstableSmall = import inputs.nixpkgs-unstable-small {
          system = prev.system;
          config.allowUnfree = true;
        };
      };
      release-2105-overlay = final: prev: {  # TODO: define these on ./lib/overlays
        release2105 = import inputs.nixpkgs-2105 {
          system = prev.system;
          config.allowUnfree = true;
        };
      };
      master-overlay = final: prev: {  # TODO: define these on ./lib/overlays
        master = import inputs.nixpkgs-master {
          system = prev.system;
          config.allowUnfree = true;
        };
      };
      overlayModules = [
        ({ ... }: { nixpkgs.overlays = [ unstable-small-overlay release-2105-overlay master-overlay ]; })
      ];

      mkHost = hostConfig:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = overlayModules ++ nixosModules ++ [ hostConfig ];
        };

    in {
      nixosConfigurations = builtins.mapAttrs
        (host: config: mkHost config) hostsConfigs;
    };
}
