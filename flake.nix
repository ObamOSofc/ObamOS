{
  description = "ObamOS - The Custom OS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, hyprland }: {
    nixosConfigurations.obamos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
        "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
        hyprland.nixosModules.default
        ({ pkgs, ... }: {
          system.stateVersion = "26.11";
          
          # Branding
          networking.hostName = "obamos";
          environment.etc."os-release".text = ''
            NAME="ObamOS"
            ID=obamos
            PRETTY_NAME="ObamOS 1.0"
            VERSION="1.0"
          '';

          # Fix the small font in TTY
          console.font = "Lat2-Terminus16";
          
          # Graphics & Desktop
          programs.hyprland.enable = true;
          services.xserver.videoDrivers = [ "modesetting" ];
          
          # Fixed Package List
          environment.systemPackages = [
            pkgs.kitty
            pkgs.waybar
            pkgs.wofi
            pkgs.kdePackages.dolphin
          ];

          # Security
          services.getty.autologinUser = null;
          users.users.root.initialHashedPassword = "";
        })
      ];
    };

    packages.x86_64-linux.iso = self.nixosConfigurations.obamos.config.system.build.isoImage;
  };
}
