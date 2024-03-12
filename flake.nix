{
  description = "Atomic Studio development utility flake";

  inputs = {
    bluebuild.url = "https://flakehub.com/f/blue-build/cli/0.8.2.tar.gz";
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";
    nix-pre-commit-hooks.url = "https://github.com/cachix/pre-commit-hooks.nix/tarball/master";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";
  };

  outputs = { self, flake-schemas, nixpkgs, nix-pre-commit-hooks, bluebuild }:
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
          src = ./.;
          
          default_stages = ["manual" "push"];
          hooks = {
            alejandra.enable = true;
            shellcheck.enable = true;
            markdownlint.enable = true;
            yamllint.enable = true;
            commitizen.enable = true;
          };
        };
      });

      packages = forEachSupportedSystem ({ system, pkgs, lib, ... }: {
        # Inherit de-annoyify flake for packages!

        build-image = pkgs.writers.writeNuBin "build-image" ''
        def "main" [--prefix (-p): string, ...recipes: string] {
          mut recipe_prefix: string = ""
          if $prefix != null {
            $recipe_prefix = $"($prefix)\/"
          }
          let final_prefix = $recipe_prefix
         
          $recipes | par-each { |recipe| do {${bluebuild.packages.${system}.bluebuild}/bin/bluebuild build $"config/recipes/($final_prefix)($recipe).yml"} & }
        }
        '';
        
        # This script is surprisingly fast!
        generate-logo = pkgs.writers.writeNuBin "generate-logo" ''
        def "main" [inputFile: string, outputFolder: string, outputName: string, extension: string, ...rest] {
          mkdir $outputFolder
          [ 16 32 64 128 256 ] | par-each { 
            |size| do { ${lib.getExe pkgs.ffmpeg} -y -i $inputFile -vf $"scale=($size):($size)" $"($outputFolder)/($outputName)-($size)x($size).($extension)" } 
          }
          ${lib.getExe pkgs.ffmpeg} -y -i $inputFile $"($outputFolder)/($outputName).($extension)" &
        }
        '';
      });

      devShells = forEachSupportedSystem ({ system, pkgs, ... }: {
        default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          packages = with pkgs; [
            git
            nixpkgs-fmt
            nushell
            bluebuild.packages.${system}.bluebuild
          ];
        };
      });
    };
}
