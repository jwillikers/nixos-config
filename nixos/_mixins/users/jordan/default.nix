{ config, desktop, lib, pkgs, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  # Only include desktop components if one is supplied.
  imports = [ ] ++ lib.optional (builtins.isString desktop) ./desktop.nix;

  environment.systemPackages = [
    # pkgs.yadm # Terminal dot file manager
  ];

  users.users.jordan = {
    description = "Jordan Williams";
    extraGroups = [
      "audio"
      "input"
      "networkmanager"
      "users"
      "video"
      "wheel"
    ]
    ++ ifExists [
      "docker"
      "podman"
    ];
    # mkpasswd -m sha-512
    hashedPassword = "$6$iH4ONfriJCTcmTr7$MqNHxbzCYAji6nrNRtoz.D2Njot1DaflNgZl.Byx0qz5QZWFDVkDi9p7lU6uvnJ2Adc4HQRbyum1SJV/p219t1";
    homeMode = "0755";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOCXKobdFsqttj7q7kuyIInjKkUsqPM+qo+imjODbqDiVAy6iU6HbKez9S0+qbW7zGbMITX/hgm+k+gyDwHLUrPna9ObJvO/uhgUqtUv1tjGf+Ch1BZ015eNRerSQdWNJKwYr+JjVQRiqMkUyhCUiuoWe+f5u58+LzXQaR1r5JmOyDORaYdbg0aq3zqwZ92dAjjPgTob3xbj3jYwWw39rcnORPdN3g1wkWSSE7xSGQb95KuaHj8Xy60KFXPAMiFaDP6OTXPy/706TLrJsZSpbPKhyoKAH7/7u54QNLxVVlfvdi7CvOoTVr4fpneWGfPMP1XB0b8hS7zjPaVtQJ/4vlvMsyi52w5FhJ5kT+MTXO7vezWkIsq8F3NmHOmJoHcrby+nfIqBmy21FjjHF/kSjM9+Cf1uguUZe0laSgYNwx+x1+Mu1rlgaghDasd6Y78P6iOi76mc5o7V+lN75B6GDo+GouB2uBavKrFuRmPxPUR33mK4jz3Wm/JBmSNX4Ib+c= jordan@pinebook-pro.jwillikers.io"
    ];
    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };
}
