{ lib, inputs, ... }: {
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
    "ssh/ssh_config.d".source = inputs.openssh-config + "/ssh/ssh_config.d";
    "ssh/sshd_config.d".source = inputs.openssh-config + "/ssh/sshd_config.d";
  };
}
