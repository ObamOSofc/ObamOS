{ config, lib, ... }: {
  environment.etc."os-release".text = ''
    NAME="ObamOS"
    ID=obamos
    PRETTY_NAME="ObamOS 1.0"
    VERSION="1.0"
    HOME_URL="https://github.com/ObamOSofc/ObamOS"
  '';
}
