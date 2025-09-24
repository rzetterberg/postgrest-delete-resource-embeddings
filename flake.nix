{
  description = "pdre";

  nixConfig.bash-prompt = "\[dev\]$ ";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-25.05;
  };

  outputs = { self, nixpkgs }: let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f rec {
      inherit system;

      pkgs = import nixpkgs { inherit system; };
    });
  in rec {
    devShells = forEachSupportedSystem ({ system, pkgs }: rec {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          postgresql
          pkg-config
          postgrest
          sqitchPg
          hurl
        ];
      };
    });
  };
}
