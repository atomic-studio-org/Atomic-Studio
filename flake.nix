{
  description = "Atomic Studio development utility flake";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";
    nix-pre-commit-hooks.url = "https://github.com/cachix/pre-commit-hooks.nix/tarball/master";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";
  };

  
  outputs = { self, flake-schemas, nixpkgs, nix-pre-commit-hooks }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f rec {
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
        inherit system;
      });
    in {
      schemas = flake-schemas.schemas;

      checks = forEachSupportedSystem ({system, pkgs,...}: {
        pre-commit-check = nix-pre-commit-hooks.lib.${system}.run {
          src = pkgs.lib.cleanSource ./.;
          # If your hooks are intrusive, avoid running on each commit with a default_states like this:
          # default_stages = ["manual" "push"];
          hooks = {
            elm-format.enable = true;
            ormolu.enable = true;
            shellcheck.enable = true;
          };
 
          # Some hooks offer custom settings that affect how they execute
          settings = {
            ormolu.defaultExtensions = [ "lhs" "hs" ];
          };          
        };
      });

      packages = forEachSupportedSystem ({ system, pkgs, lib, ... }: {
        # replace with pkgs.bluebuild whenever flake is done
        build-image = pkgs.writers.writeNuBin "build-image" ''
          def "main" [audio-system: string, recipe: string, ...rest] {
            bluebuild build config/recipe/$audio-system/$recipe.yml 
          }
        '';
        
        # This script is surprisingly fast!
        generate-logo = pkgs.writers.writeNuBin "generate-logo" ''
          def "main" [inputFile: string, outputFolder: string, outputName: string, extension: string, ...rest] {
          mkdir $outputFolder
          [ 16 32 64 128 256 ] | par-each { 
            |size| do { ${lib.getExe pkgs.ffmpeg} -y -i $inputFile -vf $"scale=($size):($size)" $"($outputFolder)/($outputName)-($size)x($size).($extension)" } & 
          }
          ${lib.getExe pkgs.ffmpeg} -y -i $inputFile $"($outputFolder)/($outputName).($extension)" &
        }
        '';
      });

      devShells = forEachSupportedSystem ({ system, pkgs, ... }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            curl
            git
            jq
            wget
            nixpkgs-fmt
            nushell
          ];
        };
      });
    };
}
