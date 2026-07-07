{
  description = "ObamOS - The Custom OS with Hyprland";

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
        {
          system.stateVersion = "26.11";
          
          # Branding
          networking.hostName = "obamos";
          environment.etc."os-release".text = ''
            NAME="ObamOS"
            ID=obamos
            PRETTY_NAME="ObamOS 1.0"
            VERSION="1.0"
          '';

          # Graphics & Desktop
          programs.hyprland.enable = true;
          services.xserver.videoDrivers = [ "modesetting" ];
          
          # Wayland Support
          environment.systemPackages = with nixpkgs.legacyPackages.x86_64-linux; [
            kitty        # Terminal
            waybar       # Status bar
            wofi         # App launcher
            dolphin      # File manager
          ];

          # Security
          services.getty.autologinUser = null;
          users.users.root.initialHashedPassword = "";

          # Bootloader
          boot.loader.grub.configurationName = "ObamOS";
        }
      ];
    };

    packages.x86_64-linux.iso = self.nixosConfigurations.obamos.config.system.build.isoImage;
  };
}
