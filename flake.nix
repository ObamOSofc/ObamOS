cat <<'EOF' > flake.nix
{
  description = "ObamOS System Builder";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.rootfs = nixpkgs.legacyPackages.x86_64-linux.buildEnv {
      name = "obamos-rootfs";
      paths = with nixpkgs.legacyPackages.x86_64-linux; [
        bashInteractive
        coreutils
        findutils
        gnugrep
      ];
    };
  };
}
EOF
