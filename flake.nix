{
  description = "pico-fido-firmwares matrix build flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];
        perSystem =
          {
            config,
            self',
            pkgs,
            ...
          }:
          let
            pico-lib = pkgs.callPackage ./lib { };
          in
          {
            packages = {
              pico-fido = pkgs.callPackage ./pkgs/pico-fido { pico-lib = pico-lib; };
              pico-fido2 = pkgs.callPackage ./pkgs/pico-fido2 { pico-lib = pico-lib; };
              pico-openpgp = pkgs.callPackage ./pkgs/pico-openpgp { pico-lib = pico-lib; };
              pico-fido-firmwares = pkgs.callPackage ./pkgs/pico-firmwares {
                pico-lib = pico-lib;
                firmwareType = "pico-fido";
              };
              pico-fido2-firmwares = pkgs.callPackage ./pkgs/pico-firmwares {
                pico-lib = pico-lib;
                firmwareType = "pico-fido2";
              };
              pico-openpgp-firmwares = pkgs.callPackage ./pkgs/pico-firmwares {
                pico-lib = pico-lib;
                firmwareType = "pico-openpgp";
              };
            };
          };
      }
    );
}
