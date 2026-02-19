{ lib, callPackage, symlinkJoin, ... }:
let
  picofidoBoards = lib.filter
    (s: s != "" && !(lib.hasPrefix "#" s))
    (lib.splitString "\n" (lib.trim (builtins.readFile ./pico-fido-boards.txt)));
  picofidoArgMatrix = lib.cartesianProduct {
    picoBoard = picofidoBoards;
    enableEdDSA = [ true false ];
  };
  picofidoFirmwares = map (args: callPackage ../pico-fido { inherit (args) picoBoard enableEdDSA; }) picofidoArgMatrix;
in
symlinkJoin {
  name = "pico-fido-firmwares";
  paths = picofidoFirmwares;
}