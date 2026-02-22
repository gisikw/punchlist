{
  description = "Punchlist — iOS task list app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            just
            rsync
            sshpass
          ];

          shellHook = ''
            echo "Punchlist dev shell"
            echo "  just --list  — available recipes"
            echo "  just check   — type-check Swift"
            echo "  just build   — simulator build"
          '';
        };
      }
    );
}
