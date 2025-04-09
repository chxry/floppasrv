{ pkgs, ... }:
let
  externalInterface = "enp0s6";
  wgInterface = "wg0";
in
{
  networking.nat = {
    enable = true;
    externalInterface = externalInterface;
    internalInterfaces = [ wgInterface ];
  };

  networking.wireguard = {
    enable = true;
    interfaces."${wgInterface}" = {
      privateKeyFile = "/root/wg-private";
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${externalInterface} -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${externalInterface} -j MASQUERADE
      '';

      peers = [
        {
          publicKey = "QApUeFyRVgO11ic3jPijx3zOiAzEkSlL28xGmd1/DWg=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
        {
          publicKey = "YlYDeoSV/0ePUIeThvtduMbKDnRgh9OvovFQYVXCT1E=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
      ];
    };
  };
}
