{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ 
    elixir_1_12
    docker-compose 
    nodejs-slim-14_x # for npm
    watchexec # for test_watch
  ];
}
