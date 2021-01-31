{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ 
    elixir_1_10
    erlangR22
    docker-compose 
    nodejs # for npm
    watchexec # for test_watch
  ];
}
