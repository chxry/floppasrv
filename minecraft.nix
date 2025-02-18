{ pkgs, ... }:
let
  screen_name = "mc-1";
in
{
  environment.shellAliases = {
    "mc-console" = "${pkgs.screen}/bin/screen -S ${screen_name} -r";
  };

  systemd.services.mc-1 = {
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      WorkingDirectory = "/root/mc-1";
      ExecStart = "${pkgs.screen}/bin/screen -DmS ${screen_name} ${pkgs.bash}/bin/bash -c '${pkgs.jdk21_headless}/bin/java -Xmx8G -jar fabric-1.20.1.jar nogui | ${pkgs.coreutils}/bin/tee >(${pkgs.systemd}/bin/systemd-cat)'";
      TimeoutStopSec = 300;
    };
  };
}
