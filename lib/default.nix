{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  cmake,
  gcc-arm-embedded,
  picotool,
  python3,
  pico-sdk,
}:
let
  mbedtlsVersions = {
    standard = {
      owner = "Mbed-TLS";
      repo = "mbedtls";
      rev = "v3.6.5";
      hash = "sha256-6vTiOsTo8+r+GWhatAize3HC4TluboUQr9AOr1nx10o=";
    };
    eddsa = {
      owner = "librekeys";
      repo = "mbedtls";
      rev = "mbedtls-3.6-eddsa";
      hash = "sha256-a2edwKskmOKMy34xsD29OW/TlfHCn5PtUKDliDGUXi8=";
    };
  };

  getMbedtls =
    enableEdDSA:
    fetchFromGitHub (if enableEdDSA then mbedtlsVersions.eddsa else mbedtlsVersions.standard);

  mkPicoCmakeFlags =
    {
      lib,
      gcc-arm-embedded,
      picoBoard,
      vidpid,
      usbVID,
      usbPID,
      enableEdDSA,
      secureBootPKey,
      extraCmakeFlags,
    }:
    [
      "-DCMAKE_C_COMPILER=${lib.getExe' gcc-arm-embedded "arm-none-eabi-gcc"}"
      "-DCMAKE_CXX_COMPILER=${lib.getExe' gcc-arm-embedded "arm-none-eabi-g++"}"
      "-DCMAKE_AR=${lib.getExe' gcc-arm-embedded "arm-none-eabi-ar"}"
      "-DCMAKE_RANLIB=${lib.getExe' gcc-arm-embedded "arm-none-eabi-ranlib"}"
    ]
    ++ lib.optionals (picoBoard != "pico") [ "-DPICO_BOARD=${picoBoard}" ]
    ++ lib.optionals (vidpid != "") [ "-DVIDPID=${vidpid}" ]
    ++ lib.optionals (usbVID != "" && usbPID != "") [
      "-DUSB_VID=${usbVID}"
      "-DUSB_PID=${usbPID}"
    ]
    ++ lib.optionals enableEdDSA [ "-DENABLE_EDDSA=ON" ]
    ++ lib.optionals (secureBootPKey != null) [ "-DSECURE_BOOT_PKEY=${secureBootPKey}" ]
    ++ extraCmakeFlags;
in
{
  inherit getMbedtls mkPicoCmakeFlags;

  mkPicoDerivation =
    {
      pname,
      version,
      src,
      repo,
      installName,
      installPath,
      enableEdDSA ? false,
      picoBoard ? "pico",
      vidpid ? "",
      usbVID ? "",
      usbPID ? "",
      secureBootPKey ? null,
      extraCmakeFlags ? [ ],
      # Nix seems to default to Release which make the image too big
      cmakeBuildType ? "MinSizeRel",
      ...
    }@args:
    let
      mbedtls = getMbedtls enableEdDSA;
    in
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit cmakeBuildType;
      pname = "${pname}-${picoBoard}${if enableEdDSA then "-eddsa" else ""}";
      version = version;

      src = src;

      strictDeps = true;

      nativeBuildInputs = [
        cmake
        gcc-arm-embedded
        picotool
        python3
      ];

      postPatch = ''
        rm -r pico-keys-sdk/mbedtls
        cp -r ${mbedtls} pico-keys-sdk/mbedtls
      '';

      PICO_SDK_PATH = "${pico-sdk.override { withSubmodules = true; }}/lib/pico-sdk/";

      cmakeFlags = mkPicoCmakeFlags {
        lib = lib;
        gcc-arm-embedded = gcc-arm-embedded;
        picoBoard = picoBoard;
        vidpid = vidpid;
        usbVID = usbVID;
        usbPID = usbPID;
        enableEdDSA = enableEdDSA;
        secureBootPKey = secureBootPKey;
        extraCmakeFlags = extraCmakeFlags;
      };

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/${installName}
        install ${installPath} $out/share/${installName}/${pname}-${picoBoard}${
          if enableEdDSA then "-eddsa" else ""
        }.uf2

        runHook postInstall
      '';

      meta = {
        changelog = "https://github.com/${repo}/releases/tag/v${version}";
        description = "FIDO Passkey for Raspberry Pico";
        homepage = "https://github.com/${repo}";
        license = lib.licenses.agpl3Only;
        platforms = pico-sdk.meta.platforms;
      };
    });
}
