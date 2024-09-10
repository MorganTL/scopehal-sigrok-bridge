{
  description = "flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      # from https://github.com/NixOS/nixpkgs/blob/ab70b01c83dd5ba876d8d79ef5cba24ef185c8c9/pkgs/applications/science/electronics/dsview/libsigrok4dsl.nix
      libsigrok4dsl = pkgs.stdenv.mkDerivation {
        pname = "libsigrok4dsl";
        version = "1.12";

        src = pkgs.fetchFromGitHub {
          owner = "DreamSourceLab";
          repo = "DSView";
          rev = "5a9481fd0697d66ce5ce0e46a8d233125e6cb5ac";
          hash = "sha256-4sEseH5OmWsesNj+c+RuAu6Oj4yn8TibaA8MnKLo7h4=";
        };

        postUnpack = ''
          export sourceRoot=$sourceRoot/libsigrok4DSL
        '';

        nativeBuildInputs = with pkgs; [
          pkg-config
          autoreconfHook
        ];

        buildInputs = with pkgs; [
          glib
          libzip
          libserialport
          libusb1
          libftdi
          systemd
          check
          alsa-lib
        ];
      };

      scopehal-sigrok-bridge = pkgs.stdenv.mkDerivation {
        pname = "scopehal-sigrok-bridge";
        version = "0.0.0";

        src = ./.;

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
          makeWrapper
        ];

        buildInputs = [
          libsigrok4dsl
          pkgs.libusb1

          # needed by libsigrok4dsl
          pkgs.pcre2
          pkgs.glib
          pkgs.libzip
          pkgs.libserialport
        ];

        # cmakeFlags = [
        #   "-Wno-error"
        #   "-DENABLE_SHARED=ON"
        #   "-Wno-deprecated"
        # ];
      };

    in
    {
      packages.x86_64-linux.default =  scopehal-sigrok-bridge;
    };
}
