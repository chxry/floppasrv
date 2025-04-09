{ pkgs, ... }:
{
  environment.shellAliases = {
    "mc-console" = "${pkgs.screen}/bin/screen -r -S";
  };

  systemd.services."minecraft@" = {
    serviceConfig = {
      StateDirectory = "minecraft/%i";
      WorkingDirectory = "%S/minecraft/%i";
      ExecStart = "${pkgs.screen}/bin/screen -DmS %i ${pkgs.bash}/bin/bash -c '${pkgs.jdk21_headless}/bin/java -Xmx8G -jar server.jar nogui | ${pkgs.coreutils}/bin/tee >(${pkgs.systemd}/bin/systemd-cat)'";
      TimeoutStopSec = 300;
    };
  };
}
