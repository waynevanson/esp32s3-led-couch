# 1. Use pre-built binary of rust via `esp-rs`
#    https://github.com/esp-rs/rust-build/releases/tag/v1.88.0.0
# 2. Install LLVM fork + GCC toolchain (crosstool-ng) for build time.
#
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=d0907b75146a0ccc1ec0d6c3db287ec287588ef6";
    flake-utils.url = "github:numtide/flake-utils";
    esp-dev-rust.url = "github:waynevanson/nixpkgs-esp-dev-rust";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    esp-dev-rust,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [esp-dev-rust.overlays.default];
        };
        rust-analyzer' = pkgs.rust-analyzer.overrideAttrs {
          version = "2025-08-25-nightly";
          src = pkgs.fetchFromGitHub {
            owner = "rust-lang";
            repo = "rust-analyzer";
            rev = "nightly";
            hash = "sha256-fuHLsvM5z5/5ia3yL0/mr472wXnxSrtXECa+pspQchA=";
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rust-analyzer'

            esp-idf-full

            # Tools required to use ESP-IDF.
            git
            wget
            gnumake

            flex
            bison
            gperf
            pkg-config
            cargo-generate

            cmake
            ninja

            ncurses5

            llvm-xtensa
            llvm-xtensa-lib
            rust-xtensa

            ldproxy
            espflash

            python3
            python3Packages.pip
            python3Packages.virtualenv
          ];
          shellHook = ''
            # fixes libstdc++ issues and libgl.so issues
            # export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [pkgs.libxml2 pkgs.zlib pkgs.stdenv.cc.cc.lib]}
            export ESP_IDF_VERSION=v5.3
            export LIBCLANG_PATH=${pkgs.llvm-xtensa-lib}/lib
            export RUSTFLAGS="--cfg espidf_time64"
          '';
        };
      }
    );
}
