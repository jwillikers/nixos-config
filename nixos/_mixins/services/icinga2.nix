_: {
  services = {
    # todo how to make?
    icinga2 = {
      enable = true;
      # todo
    };
  };
}

{config, pkgs, lib, ...}:

let
  cfg = config.services.icinga2;
in

with lib;

{
  options = {
    services.icinga2 = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = ''
          Start the Icinga2 daemon.
        '';
      };

      # user = mkOption {
      #   default = "";
      #   type = with types; uniq string;
      #   description = ''
      #     Name of the user.
      #   '';
      # };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ircSession = {
      wantedBy = [ "multi-user.target" ]; 
      requires = [ "network-online.target" ];
      after = [ "syslog.target" "network-online.target" "icingadb-redis.service" "postgresql.service" "mariadb.service" "carbon-cache.service" "carbon-relay.service" ];
      description = "Icinga host/service/network monitoring system";
      serviceConfig = {
        Type = "notify";
        NotifyAccess = "all";
        Environment = "ICINGA2_ERROR_LOG=/var/log/icinga2/error.log";
        EnvironmentFile = "/etc/sysconfig/icinga2";
        ExecStartPre = "${pkgs.icinga2}/lib/icinga2/prepare-dirs /etc/sysconfig/icinga2";
        ExecStart = "${pkgs.icinga2}/sbin/icinga2 daemon --close-stdio -e \${ICINGA2_ERROR_LOG}";
        PIDFile = "/run/icinga2/icinga2.pid";
        ExecReload = "${pkgs.icinga2}/lib/icinga2/safe-reload /etc/sysconfig/icinga2";
        TimeoutStartSec = "30m";
        KillMode = "mixed";
        User = "icinga2";
        Group = "icinga2";
      };
    };

    environment.systemPackages = [ pkgs.icinga2 ];
  };
}
