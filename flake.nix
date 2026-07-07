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
          
          # Display Manager (The Greeter)
          services.displayManager.sddm.enable = true;
          services.displayManager.sddm.wayland.enable = true;
          programs.hyprland.enable = true;

          # Create a real user
          users.users.arch = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "video" ];
            initialPassword = "password";
          };

          # System Packages
          environment.systemPackages = [
            pkgs.kitty
            pkgs.waybar
            pkgs.wofi
            pkgs.kdePackages.dolphin
          ];

          # Console Font
          console.font = "Lat2-Terminus16";
        })
      ];
    };

    packages.x86_64-linux.iso = self.nixosConfigurations.obamos.config.system.build.isoImage;
  };
}
