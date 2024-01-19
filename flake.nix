{
  description = "System configuration";


  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
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

      #unstable-overlay = final: prev: {  # TODO: define these on ./lib/overlays
        #unstable = import inputs.nixpkgs-unstable {
          #system = prev.system;
          #config.allowUnfree = true;
        #};
      #};
      #overlayModules = [
        #({ ... }: { nixpkgs.overlays = [ unstable-overlay ]; })
      #];

      mkHost = hostConfig:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          #modules = overlayModules ++ nixosModules ++ [
          modules = nixosModules ++ [
            hostConfig
          ];
        };

    in {
      nixosConfigurations = builtins.mapAttrs
        (host: config: mkHost config) hostsConfigs;
    };
}
