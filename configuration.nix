{ config, pkgs, ... }: {
  imports = [
    ./grafana/grafana.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  
  environment.systemPackages = with pkgs; [
    helix
  ];
  
  programs.git = {
    enable = true;
    config = {
      user.name = "chxry";
      user.email = "floppa9@proton.me";
    };
  };

  services.openssh.enable = true;

  services.caddy = {
    enable = true;
    virtualHosts."${config.networking.domain}".extraConfig = "root * /var/www\nfile_server";
    virtualHosts."grafana.${config.networking.domain}".extraConfig = "reverse_proxy :${toString config.services.grafana.settings.server.http_port}";
    virtualHosts."faro-collector.${config.networking.domain}".extraConfig = "reverse_proxy :3011";
  };
 
  networking = {
    hostName = "floppasrv";
    domain = "floppa.systems";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };
  
  users.users.root = {
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPd3nbQWawoku+jKEsgN0Z9EJh5EYDBYrsbBLJoeazrz floppa" ];
  };
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
