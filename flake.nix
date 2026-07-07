{
  description = "ObamOS - The Custom OS Distribution";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.obamos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
        ({ pkgs, ... }: {
          system.stateVersion = "26.11";
          
          # --- 1. Branding & Identity (100% Freedom) ---
          networking.hostName = "obamos";
          system.nixos.distroId = "obamos";
          system.nixos.label = "ObamOS-1.0";
          boot.loader.grub.configurationName = "ObamOS";
          
          # Force remove NixOS branding from boot/kernel
          boot.kernelParams = [ "logo.nologo" "vt.global_cursor_default=0" ];
          environment.etc."os-release".text = ''
            NAME="ObamOS"
            ID=obamos
            PRETTY_NAME="ObamOS 1.0"
            VERSION="1.0"
          '';

          # --- 2. ISO Optimization & Size ---
          isoImage.squashfsCompression = "zstd -Xcompression-level 19";
          documentation.enable = false;
          documentation.nixos.enable = false;
          hardware.enableAllFirmware = false; 

          # --- 3. Installer Automation ---
          environment.systemPackages = [
	    pkgs.dialog
	    pkgs.parted
	    pkgs.util-linux
            (pkgs.writeScriptBin "obamos-install.sh" (builtins.readFile ./obamos-install.sh))
          ];
          
          services.getty.autologinUser = "root";
          environment.interactiveShellInit = ''
            if [ "$XDG_VTNR" = 1 ]; then
              /run/current-system/sw/bin/obamos-install.sh
            fi
          '';

          # --- 4. User Default Folders ---
          system.activationScripts.makeFolders = ''
            mkdir -p /etc/skel/{Documents,Pictures,Videos,Downloads,Music}
          '';
        })
      ];
    };
  };
}

