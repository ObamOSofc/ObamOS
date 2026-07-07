{
  description = "ObamOS - The Custom OS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.obamos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
        "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
        {
          system.stateVersion = "26.11";
          
          # Branding Overrides
          networking.hostName = "obamos";
          
          # Force overwrite of os-release
          environment.etc."os-release" = {
            text = ''
              NAME="ObamOS"
              ID=obamos
              PRETTY_NAME="ObamOS 1.0"
              VERSION="1.0"
            '';
          };

          # Override version information
          system.nixos.label = "obamos-1.0";
          system.nixos.version = "1.0";

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
        }
      ];
    };

    packages.x86_64-linux.iso = self.nixosConfigurations.obamos.config.system.build.isoImage;
  };
}
