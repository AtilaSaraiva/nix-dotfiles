{
  description = "System configuration";


  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  };


  outputs = { self, nixpkgs, nixpkgs-unstable, nur, ... }@inputs:

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
        ) ./modules;

              mkHost = hostConfig:
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";  # how to get from host?
            specialArgs = inputs;
            modules =  nixosModules ++ [ hostConfig ];
          };

      in {
        nixosConfigurations = builtins.mapAttrs
          (host: config: mkHost config) hostsConfigs;
      };
}
