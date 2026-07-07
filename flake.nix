{
  description = "ObamOS - The Custom OS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.obamos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Include necessary modules to build an ISO
        "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
        "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
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

          # Shell Prompt
          environment.interactiveShellInit = ''
            export PS1="ObamOS \w \$ "
          '';

          # Security
          services.getty.autologinUser = null;
          users.users.root.initialHashedPassword = "";

          # Base System
          boot.plymouth.enable = false;
          services.xserver.enable = false;
          
          environment.systemPackages = with nixpkgs.legacyPackages.x86_64-linux; [
            bashInteractive
            coreutils
          ];
          
          # Tell Nix to build an ISO
          isoImage.isoName = "obamos.iso";
        }
      ];
    };

    # Build shortcut
    packages.x86_64-linux.iso = self.nixosConfigurations.obamos.config.system.build.isoImage;
  };
}
