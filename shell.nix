{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ 
    elixir_1_12
    docker-compose 
    nodejs # for npm
    watchexec # for test_watch
  ];
}
