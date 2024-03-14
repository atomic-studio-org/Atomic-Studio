{
  description = "Atomic Studio development utility flake";

  inputs = {
    utility-flake.url = "github:atomic-studio-org/Utility-Flake-Library";
    bluebuild.url = "https://flakehub.com/f/blue-build/cli/0.8.2.tar.gz";
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";
  };

  outputs = {
    self,
    flake-schemas,
    nixpkgs,
    bluebuild,
    utility-flake,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    schemas = flake-schemas.schemas;

    checks = forEachSupportedSystem ({ pkgs }: {
      inherit (utility-flake.checks.${pkgs.system}) pre-commit-check;
    });

    packages = forEachSupportedSystem ({
      pkgs,
    }: {
      inherit (utility-flake.packages.${pkgs.system}) cosign-generate;
      
      build-image = pkgs.writers.writeNuBin "build-image" ''
        def "main" [--prefix (-p): string, ...recipes: string] {
          mut recipe_prefix: string = ""
          if $prefix != null {
            $recipe_prefix = $"($prefix)\/"
          }
          let final_prefix = $recipe_prefix

          $recipes | par-each { |recipe| do {${bluebuild.packages.${pkgs.system}.bluebuild}/bin/bluebuild build $"config/recipes/($final_prefix)($recipe).yml" } out> $"/tmp/bluebuild-($recipe).log" & }
        }
      '';

      # This script is surprisingly fast!
      generate-logo = pkgs.writers.writeNuBin "generate-logo" ''
        def "main" [inputFile: string, outputFolder: string, outputName: string, extension: string, ...rest] {
          mkdir $outputFolder
          [ 16 32 64 128 256 ] | par-each {
            |size| do { ${pkgs.lib.getExe pkgs.ffmpeg} -y -i $inputFile -vf $"scale=($size):($size)" $"($outputFolder)/($outputName)-($size)x($size).($extension)" }
          }
          ${pkgs.lib.getExe pkgs.ffmpeg} -y -i $inputFile $"($outputFolder)/($outputName).($extension)" &
        }
      '';
    });

    devShells = forEachSupportedSystem ({
      pkgs,
    }: {
      default = pkgs.mkShell {
        inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
        packages = with pkgs; [ bluebuild.packages.${system}.bluebuild nushell git jq yq ];
      };
    });
  };
}
