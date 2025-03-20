{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in with pkgs;
      {
        devShells.default = mkShell {
          buildInputs = [ elixir_1_18 elixir-ls inotify-tools hurl ];
        };
      }
    );
}
