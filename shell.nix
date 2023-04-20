{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ 
    beam.packages.erlangR23.elixir_1_13
    docker-compose 
    nodejs-slim-14_x # for npm
    watchexec # for test_watch
  ];
}
