{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ 
    elixir 
    erlang 
    docker-compose 
    nodejs # for npm
    watchexec # for test_watch
  ];
}
