{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  # env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = with pkgs; [
    mdbook
    mdbook-admonish
    mdbook-cmdrun
    mdbook-i18n-helpers
    mdbook-linkcheck
    mdbook-toc
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  # scripts.hello.exec = ''
  #   echo hello from $GREET
  # '';

  # enterShell = ''
  #   hello
  #   git --version
  # '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  # enterTest = ''
  #   echo "Running tests"
  #   git --version | grep --color=auto "${pkgs.git.version}"
  # '';

  # https://devenv.sh/pre-commit-hooks/
  pre-commit = {
    hooks = {
      commitizen.enable = true;
      shellcheck = {
        enable = true;
        entry = lib.mkForce "${pkgs.shellcheck}/bin/shellcheck -x";
      };
      shfmt.enable = true;
      statix.enable = true;
      typos = {
        enable = true;
        excludes = [
          "theme/highlight.js"
        ];
      };
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
