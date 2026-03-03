{
  lib,
  callPackage,
  symlinkJoin,
  stdenvNoCC,
  fetchFromGitHub,
  cmake,
  gcc-arm-embedded,
  picotool,
  python3,
  pico-sdk,
  pico-lib ? import ../../lib {
    inherit
      lib
      stdenvNoCC
      fetchFromGitHub
      cmake
      gcc-arm-embedded
      picotool
      python3
      pico-sdk
      ;
  },
  firmwareType ? "pico-fido",
}:
let
  picoBoards = lib.filter (s: s != "" && !(lib.hasPrefix "#" s)) (
    lib.splitString "\n" (lib.trim (builtins.readFile ./pico-boards.txt))
  );
  picoArgMatrix = lib.cartesianProduct {
    picoBoard = picoBoards;
    enableEdDSA = [
      true
      false
    ];
  };
  pkg =
    if firmwareType == "pico-fido" then
      ../pico-fido
    else if firmwareType == "pico-fido2" then
      ../pico-fido2
    else if firmwareType == "pico-openpgp" then
      ../pico-openpgp
    else
      null;

  firmwares = map (
    args:
    callPackage pkg {
      pico-lib = pico-lib;
      inherit (args) picoBoard enableEdDSA;
    }
  ) picoArgMatrix;
in
symlinkJoin {
  name = "${firmwareType}-firmwares";
  paths = firmwares;
}
