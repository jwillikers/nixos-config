{ lib, ... }: {
  services = {
    # todo
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = lib.mkDefault "no";
      };
    };
  };
  programs.ssh.startAgent = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  environment.etc = {
    "ssh/ssh_config.d".source = openssh-config.outPath + "/ssh/ssh_config.d";
    "ssh/sshd_config.d".source = openssh-config.outPath + "/ssh/sshd_config.d";
  };
}
