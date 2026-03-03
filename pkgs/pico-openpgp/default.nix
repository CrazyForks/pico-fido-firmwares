{
  lib,
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

  picoBoard ? "pico",
  vidpid ? "",
  usbVID ? "",
  usbPID ? "",
  enableEdDSA ? false,
  secureBootPKey ? null,
  extraCmakeFlags ? [ ],
}:
assert lib.assertMsg (
  (vidpid == "") || (usbVID == "" && usbPID == "")
) "pico-openpgp: Arguments 'vidpid' and 'usbVID/usbPID' could not be set at the same time.";
pico-lib.mkPicoDerivation rec {
  pname = "pico-openpgp";
  version = "4.4.2-librekeys";

  src = fetchFromGitHub {
    owner = "librekeys";
    repo = "pico-openpgp";
    rev = "v${version}";
    hash = "sha256-hpY2Mwz4puK0VA6DkzLhgUAP6HaISTPqcwXBCrMkKlE=";
    fetchSubmodules = true;
  };

  repo = "librekeys/pico-openpgp";
  installName = "pico-openpgp";
  installPath = "pico_openpgp.uf2";

  inherit
    picoBoard
    vidpid
    usbVID
    usbPID
    enableEdDSA
    secureBootPKey
    extraCmakeFlags
    ;
}
