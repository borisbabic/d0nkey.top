{ pkgs, lib, config, inputs, ... }:
let 
  erlangVersion = "erlang_27";
  elixirVersion = "elixir_1_18";
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in {
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [ 
    pkgs.git
    pkgs.nodejs
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    pkgs.inotify-tools
  ];

  # erlangVersion = "erlang_27";
  # elixirVersion = "elixir_1_18";
  # https://devenv.sh/languages/
  languages.elixir.enable = true;
  languages.elixir.package = pkgs-unstable.beam.packages.${erlangVersion}.${elixirVersion};

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
  '';

  enterShell = ''
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
