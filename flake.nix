{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = { self, nixpkgs }: {
    nixosConfigurations.floppasrv = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [ ./hardware-configuration.nix ./configuration.nix ];
    };
  };
}
