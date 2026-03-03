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
  pname = "pico-fido2";
  version = "7.4.2-librekeys";

  src = fetchFromGitHub {
    owner = "librekeys";
    repo = "pico-fido2";
    rev = "v${version}";
    hash = "sha256-UA3ibvwaOaCfy7KTfOF7B1gxwE4k+dErNsTxU/FTaW4=";
    fetchSubmodules = true;
  };

  repo = "librekeys/pico-fido2";
  installName = "pico-fido2";
  installPath = "pico_fido2.uf2";

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
