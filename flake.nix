{
  description = "ObamOS Distribution";
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.obamos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
        ({ pkgs, ... }: {
          system.stateVersion = "26.11";
          networking.hostName = "obamos";
          
          # Branding
          system.nixos.distroId = "obamos";
          boot.loader.grub.splashImage = ./branding/assets/logo.png;
          boot.kernelParams = [ "logo.nologo" "vt.global_cursor_default=0" ];
          
          # Plymouth Splash
          boot.plymouth = {
            enable = true;
            theme = "my-theme";
            themePackages = [ (pkgs.stdenv.mkDerivation {
              name = "my-plymouth-theme";
              src = ./branding/plymouth;
              installPhase = "cp -r . $out";
            }) ];
          };

          environment.systemPackages = with pkgs; [
            dialog git parted util-linux hyprland waybar kitty rofi-wayland swaynotificationcenter 
            (writeScriptBin "obamos-install.sh" (builtins.readFile ./obamos-install.sh))
          ];

          services.displayManager.sddm.enable = true;
          services.getty.autologinUser = "root";
          environment.interactiveShellInit = ''
            if [ "$XDG_VTNR" = 1 ]; then /run/current-system/sw/bin/obamos-install.sh; fi
          '';

          isoImage.squashfsCompression = "zstd -Xcompression-level 19";
        })
      ];
    };
  };
}
