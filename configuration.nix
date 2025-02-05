{ pkgs, ... }: {
  networking.hostName = "floppasrv";
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
    
  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [
    helix
  ];
  programs = {
    git = {
      enable = true;
      config = {
        user.name = "chxry";
        user.email = "floppa9@proton.me";
      };
    };
  };
  
  users.users.root = {
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPd3nbQWawoku+jKEsgN0Z9EJh5EYDBYrsbBLJoeazrz floppa" ];
  };
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
