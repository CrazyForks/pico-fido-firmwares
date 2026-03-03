# pico-fido-firmwares

A custom build pico-fido firmware(s) with LibreKeys applied patches

## Build with Flakes

```bash
# Build a specific firmware
nix build .#pico-fido
nix build .#pico-fido2
nix build .#pico-openpgp

# Build all firmware variants (matrix build)
nix build .#pico-fido-firmwares
nix build .#pico-fido2-firmwares
nix build .#pico-openpgp-firmwares
```

For custom parameters, see the Non-Flakes section below (or modify `flake.nix` directly).

## Build with Nix (Non-Flakes)

```bash
# Basic build (uses defaults)
nix-build -E 'with import <nixpkgs> {}; callPackage ./pkgs/pico-fido/default.nix {}'
nix-build -E 'with import <nixpkgs> {}; callPackage ./pkgs/pico-fido2/default.nix {}'
nix-build -E 'with import <nixpkgs> {}; callPackage ./pkgs/pico-openpgp/default.nix {}'

# Build matrix (all variants)
nix-build -E 'with import <nixpkgs> {}; callPackage ./pkgs/pico-firmwares/default.nix {}' -A pico-fido-firmwares
```

### Custom Parameters

```bash
nix-build -E 'with import <nixpkgs> {}; callPackage ./pkgs/pico-fido/default.nix {
  picoBoard = "waveshare_rp2350_one";
  vidpid = "Yubikey5";
  extraCmakeFlags = [ "-DPICO_DEBUG_INFO_IN_RELEASE=ON" ];
}'
```

### Available Parameters

| Parameter         | Default  | Description                                                  |
| ----------------- | -------- | ------------------------------------------------------------ |
| `picoBoard`       | `"pico"` | Target board (e.g., `pico`, `pico2`, `waveshare_rp2350_one`) |
| `vidpid`          | `""`     | VID/PID string (e.g., `Yubikey5`)                            |
| `usbVID`          | `""`     | USB Vendor ID (alternative to vidpid)                        |
| `usbPID`          | `""`     | USB Product ID (alternative to vidpid)                       |
| `enableEdDSA`     | `false`  | Enable EdDSA support                                         |
| `extraCmakeFlags` | `[]`     | Additional cmake flags                                       |
| `secureBootPKey`  | `null`   | Path to secure boot private key (NOT TESTED YET!)            |

**Note:** `vidpid` and `usbVID/usbPID` cannot be used together.
