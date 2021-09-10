{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
    rust-overlay.url = github:oxalica/rust-overlay;
  };
  outputs = { nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlay ];
        };
        rust = pkgs.rust-bin.stable.latest.default.override {
          targets = [ target ];
          extensions = [ "rust-src" ];
        };
        target = "x86_64-unknown-linux-musl";
        pkg = pkgs.rustPlatform.buildRustPackage {
          name = "nix-user-chroot";
          src = ./.;
          cargoSha256 = "sha256-zu6aryzfYL9RUOgmQkMZ6sS0mUcClT1cGYqjxHiZ2S8";
          doCheck = false;

          # use the correct rust
          rustc = rust;
          cargo = rust;
          inherit target;
        };
      in
      {
        defaultPackage = pkg;
        devShell = with pkgs; mkShell {
          packages = [ rnix-lsp rust-analyzer ];
          buildInputs = [ rust ];
        };
      }
    );
}
