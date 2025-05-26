{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "aqua";
  version = "2.25.1"; # Update this version as needed

  # For binary installation
  src = pkgs.fetchurl {
    url = "https://github.com/aquaproj/aqua/releases/download/v${version}/aqua_darwin_arm64.tar.gz";
    sha256 = "1g0jzyfwgvc9w5rk7i0srn9xwsi5inzz50idm63jd8zh8x2x1jln";
  };

  # No build phase needed for binary installation
  dontBuild = true;

  # Need to set sourceRoot to the current directory since the tarball doesn't have a directory structure
  setSourceRoot = "sourceRoot=`pwd`";

  installPhase = ''
    mkdir -p $out/bin $out/share/doc/aqua
    install -m755 aqua $out/bin/aqua
    install -m644 LICENSE README.md $out/share/doc/aqua/
  '';

  meta = with pkgs.lib; {
    description = "Declarative CLI Version Manager";
    homepage = "https://aquaproj.github.io/";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ ];
  };
}
