# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  #imports =
  #  [ # Include the results of the hardware scan.
  #    ./hardware-configuration.nix
  #  ];

  # Bootloader.
  #boot.loader.grub.enable = true;
  #boot.loader.grub.device = "/dev/nvme0n1";
  #boot.loader.grub.useOSProber = true;
  boot.loader.systemd-boot.enable = true;

  boot.kernel.sysctl = { "vm.swappiness" = 10; };

  # networking.hostName = "ada"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hosts = {
    "192.168.0.115" = [ "tower" ];
    "127.0.0.1" = [
      "goodlife.local"
      "app.goodlife.local"
      "portal.goodlife.local"
      "api.goodlife.local"
      "glide.goodlife.local"
      "leads.goodlife.local"
      "cms.goodlife.local"
      "logs.goodlife.local"
      "phpmyadmin.goodlife.local"
    ];
    "::1" = [
      "goodlife.local"
      "app.goodlife.local"
      "portal.goodlife.local"
      "api.goodlife.local"
      "glide.goodlife.local"
      "leads.goodlife.local"
      "cms.goodlife.local"
      "logs.goodlife.local"
      "phpmyadmin.goodlife.local"
    ];
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 9001 9002 ];
    extraCommands = ''
      # Redirect port 80 to 9001
      iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 9001
      # Redirect port 443 to 9002
      iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 9002
      # For local connections (from the same machine)
      iptables -t nat -A OUTPUT -p tcp -d 127.0.0.1 --dport 80 -j REDIRECT --to-ports 9001
      iptables -t nat -A OUTPUT -p tcp -d 127.0.0.1 --dport 443 -j REDIRECT --to-ports 9002
    '';
    extraStopCommands = ''
      iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 9001 2>/dev/null || true
      iptables -t nat -D PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 9002 2>/dev/null || true
      iptables -t nat -D OUTPUT -p tcp -d 127.0.0.1 --dport 80 -j REDIRECT --to-ports 9001 2>/dev/null || true
      iptables -t nat -D OUTPUT -p tcp -d 127.0.0.1 --dport 443 -j REDIRECT --to-ports 9002 2>/dev/null || true
    '';
  };
  security.pki.certificateFiles = [ /home/matt/sites/goodlife/goodlife-docker/certs/ca/ca-cert.pem ];
  fileSystems."/mnt/tower/work" = {
    device = "tower:/mnt/user/work";
    options = [ "x-systemd.automount" "noauto" ];
    fsType = "nfs";
  };
  services.rpcbind.enable = true; # needed for NFS
  systemd.mounts = [
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime";
      };
      what = "tower:/mnt/user/work";
      where = "/mnt/tower/work";
    }
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime";
      };
      what = "tower:/mnt/user/files";
      where = "/mnt/tower/files";
    }
  ];

 systemd.automounts = [
   {
     wantedBy = [ "multi-user.target" ];
     automountConfig = {
       TimeoutIdleSec = "600";
     };
     where = "/mnt/tower/work";
   }
   {
     wantedBy = [ "multi-user.target" ];
     automountConfig = {
       TimeoutIdleSec = "600";
     };
     where = "/mnt/tower/files";
   }
 ];

  # NVIDIA Drivers
  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.xwayland.enable = true;
  programs.kdeconnect = {
    enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  # services.blueman.enable = true;

  # hardware.xone.enable = true; # support for the xbox controller USB dongle
  hardware.xpadneo.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

    # Fonts
  fonts.packages = with pkgs; [
    # (nerdfonts.override { fonts = [ "UbuntuMono" ]; })
    pkgs.nerd-fonts.ubuntu-mono
  ];

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # enable zsh and oh my zsh
  users.defaultUserShell=pkgs.zsh; 
  programs = {
    zsh = {
        enable = true;
        autosuggestions.enable = true;
        zsh-autoenv.enable = true;
        syntaxHighlighting.enable = true;
        shellInit = "fastfetch --data ' \$1
⠀⠀⠀⠀⢀⣠⣴⣶⣿⣿⣿⣿⣷⣶⣄⡀⠀⠀⠀⢰⣶⣶⣶⣶⠀⠀⠀⠀⠀⠀⠀⠀\$2⣴⣶⣶⣶\$1⠀⠀⠀⠀
⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⣼⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀\$2⣿⣿⣿⡟\$1⠀⠀⠀⠀
⠀⣰⣿⣿⣿⣿⡿⠟⠋⠉⠙⠻⣿⣿⣿⣿⣿⡀⢀⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀\$2⢸⣿⣿⣿⡇\$1⠀⠀⠀⠀
⢰⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠁⢸⣿⣿⣿⣿⠀⠀⠀\$2⢠⣤⣤⣤⣤⣼⣿⣿⣿⣤⣤⣤⣤⡤\$1
⣿⣿⣿⣿⡟⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⠃⣾⣿⣿⣿⡇⠀⠀⠀\$2⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇\$1
⣿⣿⣿⣿⣷⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⡟⢀⣿⣿⣿⣿⠃⠀⠀\$2⠐⠛⠛⠛⠛⢻⣿⣿⣿⡟⠛⠛⠛⠛⠃\$1
⢻⣿⣿⣿⣿⣷⣄⣀⣀⣠⣴⣾⣿⣿⣿⡿⠁⢸⣿⣿⣿⣿⣀⣀⣀⣀⣀⣀⠀⠀\$2⣾⣿⣿⣿\$1⠀⠀⠀⠀⠀⠀
⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀\$2⢀⣿⣿⣿⡏\$1⠀⠀⠀⠀⠀⠀
⠀⠀⠈⠛⠿⢿⣿⣿⣿⡿⠿⠟⠋⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀\$2⠸⠿⠿⠿⠇\$1⠀⠀⠀⠀

            \$2GOOD  LIFE  PLUS\$1
 '";
        ohMyZsh = {
          enable = true;
          theme = "robbyrussell";
          plugins = [
            "git"
            "npm"
            "history"
            "laravel"
          ];
        };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matt = {
    isNormalUser = true;
    description = "Matt Rose";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
  # nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    kdePackages.kate
    htop
    git
    # openrgb-with-all-plugins
    #neofetch
    #afetch
    fastfetch
    pkgs.terminator
    pkgs.zsh
    pkgs.php82
    pkgs.php82Packages.composer
    pkgs.nodejs_22
    dbeaver-bin
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
    #podman-compose # start group of containers for dev
    podman-desktop
    firefox
    google-chrome
    pkgs.filezilla
    pkgs.gnucash
    libreoffice-qt
    hunspell
    hunspellDicts.en_GB-ise
    slack
    #whatsapp-for-linux
    # teams-for-linux
    zoom-us
    supersonic-wayland
    jellyfin-media-player
    inkscape
    thunderbird
    bruno
    opencode
    warp-terminal
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
       bbenoist.nix
       eamodio.gitlens
       #rangav.vscode-thunder-client
       catppuccin.catppuccin-vsc
       #onecentlin.laravel-blade
       #amiralizadeh9480.laravel-extra-intellisense
       pkief.material-icon-theme
       #ikappas.phpcs
       #quick-lint.quick-lint-js
       bradlc.vscode-tailwindcss
      ];
    })

    lmstudio

    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    })
    mangohud
    steam-run
    heroic
    gogdl
    dolphin-emu
    airshipper
    (prismlauncher.override {
      # withWaylandGLFW=true;
      jdks = [
        javaPackages.compiler.temurin-bin.jdk-25
        javaPackages.compiler.temurin-bin.jre-21
        javaPackages.compiler.temurin-bin.jre-17
        javaPackages.compiler.temurin-bin.jre-11
        javaPackages.compiler.temurin-bin.jre-8
      ];
    })
    # (retroarch.withCores (cores: with cores; [
    #   genesis-plus-gx
    #   snes9x
    #   beetle-psx
    #   pcsx2
    #   scummvm
    # ]))
  ];

  # OpenRGB
  # services.hardware.openrgb.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Games
  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Dirty hack to make nix build
  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
    "mbedtls-2.28.10"
  ];


  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # networking.firewall.allowedTCPPorts = [ 80 443 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade = {
    enable = true;
  };

}
