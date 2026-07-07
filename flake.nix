{
  description = "ObamOS - A Custom NixOS Distribution";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.obamos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # 1. Main System Configuration
        {
          system.stateVersion = "26.11";
          
          # Custom Branding
          environment.etc."os-release".text = ''
            NAME="ObamOS"
            ID=obamos
            PRETTY_NAME="ObamOS 1.0"
            VERSION="1.0"
            HOME_URL="https://github.com/ObamOSofc/ObamOS"
          '';

          # Minimal Boot Configuration
          boot.plymouth.enable = false;
          boot.loader.grub.configurationName = "ObamOS";
          
          environment.systemPackages = with nixpkgs.legacyPackages.x86_64-linux; [
            bashInteractive
            coreutils
            hyprland
          ];

          services.xserver.enable = true;
        }

        # 2. Build as an ISO image (Standard NixOS method)
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ];
    };
  };
}