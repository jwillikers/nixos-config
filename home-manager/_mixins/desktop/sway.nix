{ config, lib, pkgs, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use foot as the default terminal
      terminal = "foot"; 
      startup = [
        # Launch Firefox on start
        # {command = "firefox";}
      ];
    };
  };

# xdg.configFile."i3blocks/config".source = ./i3blocks.conf;
# home.file.".gdbinit".text = ''
      # set auto-load safe-path /nix/store
  # '';
}
