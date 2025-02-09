{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    floppasite.url = "github:chxry/floppasite";
  };
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.floppasrv = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./hardware-configuration.nix ./configuration.nix ];
    };
  };
}
