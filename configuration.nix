{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./modules/grafana.nix
    ./modules/minecraft.nix
    ./modules/wireguard.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    helix
    nil
    nixfmt-rfc-style
  ];

  programs.git = {
    enable = true;
    config = {
      user.name = "chxry";
      user.email = "floppa9@proton.me";
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.floppa.grafana.enable = true;
  services.floppa-files.enable = true;

  services.caddy = {
    enable = true;
    virtualHosts = {
      "${config.networking.domain}".extraConfig = ''
        root * ${inputs.floppasite.packages.aarch64-linux.default}
        file_server
      '';
      "files.${config.networking.domain}".extraConfig =
        "reverse_proxy :${toString config.services.floppa-files.port}";
      "grafana.${config.networking.domain}".extraConfig =
        "reverse_proxy :${toString config.services.floppa.grafana.ports.grafana}";
      "faro-collector.${config.networking.domain}".extraConfig =
        "reverse_proxy :${toString config.services.floppa.grafana.ports.faro}";

      "map.${config.networking.domain}".extraConfig = "reverse_proxy :8100";
    };
  };

  networking = {
    hostName = "floppasrv";
    domain = "floppa.systems";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        25565
      ];
      allowedUDPPorts = [ 51820 ];
    };
  };
  
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPd3nbQWawoku+jKEsgN0Z9EJh5EYDBYrsbBLJoeazrz floppa"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "23.11";
}
