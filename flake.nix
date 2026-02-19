{
  description = "pico-fido-firmwares matrix build flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
        perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          picofidoBoards = lib.filter
            (s: s != "" && !(lib.hasPrefix "#" s))
            (lib.splitString "\n" (lib.trim (builtins.readFile ./pico-fido-boards.txt)));
          picofidoArgMatrix = lib.cartesianProduct {
            picoBoard = picofidoBoards;
            enableEdDSA = [ true false ];
          };
          picofidoFirmwares = map (args: pkgs.callPackage ./pkgs/pico-fido/default.nix { inherit (args) picoBoard enableEdDSA; }) picofidoArgMatrix;
        in
        {
          packages = {
            pico-fido = pkgs.callPackage ./pkgs/pico-fido/default.nix { };
            pico-fido-firmwares = pkgs.symlinkJoin {
              name = "pico-fido-firmwares";
              paths = picofidoFirmwares;
            };
          };
        };
      }
    );
}
