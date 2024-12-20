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
  scripts = {
    edk2-console = {
      description = "Launch UART workspace";
      exec = ''
        ${lib.getExe pkgs.tmux} kill-session -t edk2-console
        sleep 1 # wait for picocom to be closed to release UART resources
        ${lib.getExe pkgs.tmux} new-session -d -s edk2-console "${lib.getExe pkgs.picocom} -b 115200 /dev/$EDK2_SE_UART | ${lib.getExe' pkgs.coreutils "tee"} logs/se.log"
        ${lib.getExe pkgs.tmux} set-option mouse on
        ${lib.getExe pkgs.tmux} split-window -h "${lib.getExe pkgs.picocom} -b 460800 --imap lfcrlf /dev/$EDK2_EC_UART | ${lib.getExe' pkgs.coreutils "tee"} logs/ec.log"
        ${lib.getExe pkgs.tmux} split-window -v "${lib.getExe pkgs.picocom} -b 115200 /dev/$EDK2_DEBUG_UART | ${lib.getExe' pkgs.coreutils "tee"} logs/debug.log"
        ${lib.getExe pkgs.tmux} split-window -v -t 0 "${lib.getExe pkgs.picocom} -b 115200 /dev/$EDK2_AP_UART | ${lib.getExe' pkgs.coreutils "tee"} logs/ap.log"
        ${lib.getExe pkgs.tmux} attach-session -t edk2-console
      '';
    };
    edk2-build = {
      description = "Build Debian package";
      exec = ''
        .github/common/build-deb | ${lib.getExe' pkgs.coreutils "tee"} logs/build.log
      '';
    };
  };

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
