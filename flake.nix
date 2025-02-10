{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    floppasite.url = "git+https://github.com/chxry/floppasite?submodules=1";
    floppa-files.url = "git+https://github.com/chxry/floppa-files?submodules=1";
  };
  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations.floppasrv = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
          inputs.floppa-files.nixosModules.default
        ];
      };
    };
}
