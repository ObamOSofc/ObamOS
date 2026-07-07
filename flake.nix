{
  description = "ObamOS - The Custom Distribution";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.obamos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ({ pkgs, lib, ... }: {
          system.stateVersion = "26.11";
          networking.hostName = "obamos";
          
          # --- 1. Branding ---
          boot.loader.grub.splashImage = ./branding/assets/logo.png;
          system.nixos.distroId = "obamos";
          boot.kernelParams = [ "logo.nologo" "vt.global_cursor_default=0" ];
          
          environment.etc."os-release".text = ''
            NAME="ObamOS"
            ID=obamos
            PRETTY_NAME="ObamOS 1.0"
          '';

          # --- Plymouth Splash ---
          boot.plymouth = {
            enable = true;
            theme = "my-theme";
            themePackages = [ (pkgs.stdenv.mkDerivation {
              name = "my-plymouth-theme";
              src = ./branding/plymouth;
              installPhase = "cp -r . $out";
            }) ];
          };

          # --- 2. System Packages ---
          environment.systemPackages = with pkgs; [
            dialog git parted util-linux 
            hyprland waybar kitty rofi
            brightnessctl pipewire wireplumber networkmanagerapplet
            (writeScriptBin "obamos-install.sh" (builtins.readFile ./obamos-install.sh))
          ];

          # --- 3. Services & Automation ---
          services.displayManager.sddm = { enable = true; wayland.enable = true; };
          programs.hyprland.enable = true;
          
          # FIX: Force the root login to override the installer profile
          services.getty.autologinUser = lib.mkForce "root";
          
          environment.interactiveShellInit = ''
            if [ "$XDG_VTNR" = 1 ]; then /run/current-system/sw/bin/obamos-install.sh; fi
          '';

          # --- 4. ISO Optimizations ---
          isoImage.squashfsCompression = "zstd -Xcompression-level 19";
          documentation.enable = false;
        })
      ];
    };

    packages.x86_64-linux.default = self.nixosConfigurations.obamos.config.system.build.isoImage;
  };
}