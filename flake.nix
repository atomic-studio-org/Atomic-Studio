{
  description = "Atomic Studio development utility flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    pkl.url = "github:tulilirockz/apple-pkl-flake";
    blue-build.url = "github:blue-build/cli";
  };

  outputs =
    { self, nixpkgs, pkl, blue-build }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
      ];
      forEachSupportedSystem =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f { pkgs = import nixpkgs { inherit system; }; });
    in
    {
      packages = forEachSupportedSystem (
        { pkgs }:
        {
          generate-logo = pkgs.writers.writeNuBin "generate-logo" ''
            def "main" [inputFile: string, outputFolder: string, outputName: string, extension: string, ...rest] {
              mkdir $outputFolder
              [ 16 32 64 128 256 ] | par-each {
                |size| do { ${pkgs.lib.getExe pkgs.ffmpeg} -y -i $inputFile -vf $"scale=($size):($size)" $"($outputFolder)/($outputName)-($size)x($size).($extension)" }
              }
              ${pkgs.lib.getExe pkgs.ffmpeg} -y -i $inputFile $"($outputFolder)/($outputName).($extension)" &
            }
          '';
        }
      );

      formatter = forEachSupportedSystem ({ pkgs }: pkgs.nixfmt-rfc-style);

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nushell
              git
              jq
              yq
              jsonnet
              openssl
              inputs.pkl.packages.${pkgs.system}.pkl
              inputs.blue-build.packages.${pkgs.system}.default
            ];
          };
        }
      );
    };
}
