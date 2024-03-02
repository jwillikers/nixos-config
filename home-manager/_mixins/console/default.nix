{ config, lib, pkgs, ... }: {
  home = {
    file = {
      "${config.xdg.configHome}/neofetch/config.conf".text = builtins.readFile ./neofetch.conf;
    };
    packages = with pkgs; [
      # ffmpeg-headless # Terminal video encoder
      # ripgrep # Modern Unix `grep`
      # yq-go # Terminal `jq` for YAML
      libtree
      vim
    ];

    sessionVariables = {
      EDITOR = "vim";
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      SYSTEMD_EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  programs = {
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batgrep
        batwatch
        prettybat
      ];
      config = {
        style = "plain";
      };
    };
    dircolors = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    fish = {
      enable = true;
      shellAliases = {
        cat = "bat --paging=never --style=plain";
        diff = "diffr";
        glow = "glow --pager";
        htop = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
        ip = "ip --color --brief";
        less = "bat --paging=always";
        more = "bat --paging=always";
        top = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
        tree = "exa --tree";
      };
    };
    git = {
      enable = true;
      delta = {
        enable = true;
        options = {
          features = "decorations";
          navigate = true;
          side-by-side = true;
        };
      };
      aliases = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
      extraConfig = {
        push = {
          default = "matching";
        };
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "main";
        };
      };
      ignores = [
        "*.log"
        "*.out"
        ".DS_Store"
        "bin/"
        "dist/"
        "result"
      ];
    };
    gpg.enable = true;
    home-manager.enable = true;
    nix-index.enable = true;
    info.enable = true;
    jq.enable = true;
    vim = {
      enable = true;
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "curses";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = lib.mkIf isLinux "sd-switch";

  xdg = {
    enable = isLinux;
    userDirs = {
      enable = isLinux;
      createDirectories = lib.mkDefault true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
      };
    };
  };
}
