{
  description = "ObamOS - The Custom OS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.obamos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Use a minimal profile instead of the full installer
        "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
        {
          system.stateVersion = "26.11";
          
          # 1. Branding & Identity
          networking.hostName = "obamos";
          environment.etc."os-release".text = ''
            NAME="ObamOS"
            ID=obamos
            PRETTY_NAME="ObamOS 1.0"
            VERSION="1.0"
          '';

          # 2. Shell & Prompt
          environment.interactiveShellInit = ''
            export PS1="ObamOS \w \$ "
          '';

          # 3. Security: Require Password (No Autologin)
          services.getty.autologinUser = null;
          users.users.root.initialHashedPassword = ""; # Empty for now, but you can set a custom one

          # 4. Minimal System
          boot.plymouth.enable = false;
          services.xserver.enable = false;
          
          environment.systemPackages = with nixpkgs.legacyPackages.x86_64-linux; [
            bashInteractive
            coreutils
          ];
        }
      ];
    };
  };
}
