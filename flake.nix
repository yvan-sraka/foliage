{
  description = "Foliage is a tool to create custom Haskell package repositories, in a fully reproducible way.";

  inputs = {
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    haskellNix.url = "github:input-output-hk/haskell.nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
    let
      overlays = [ haskellNix.overlay
        (final: prev: {
          foliage =
            final.haskell-nix.project' {
              src = final.haskell-nix.haskellLib.cleanGit {
                name = "foliage-src";
                src = ./.;
              };
              compiler-nix-name = "ghc8107";
              shell.tools = {
                cabal = {};
                hlint = {};
                haskell-language-server = {};
              };
              shell.buildInputs = with pkgs; [
                nixpkgs-fmt
              ];
            };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.foliage.flake {
        # This adds support for `nix build .#js-unknown-ghcjs-cabal:hello:exe:hello`
        # crossPlatforms = p: [p.ghcjs];
      };
    in flake // {
      defaultPackage = flake.packages."foliage:exe:foliage";
    });
}
