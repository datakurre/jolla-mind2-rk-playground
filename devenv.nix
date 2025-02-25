{ pkgs, config, ... }:
{
  imports = [
    ./devenv/modules/airockchip.nix
    ./devenv/modules/python.nix
  ];

  languages.python.interpreter = pkgs.python310;
  languages.python.pyprojectOverrides = final: prev: {
    "hatchling" = prev."hatchling".overrideAttrs (old: {
      propagatedBuildInputs = [ final."editables" ];
    });
  };

  packages = [
    config.languages.python.uv.package
    (pkgs.buildFHSEnv {
      name = "python";
      targetPkgs = pkgs: [
        config.outputs.airockchip.librknnrt
        config.outputs.airockchip.librkllmrt
        config.outputs.python.virtualenv
      ];
      multiArch = true;
      runScript = "python";
    })
  ];

  enterShell = ''
    unset PYTHONPATH
    export UV_NO_SYNC=1
    export UV_PYTHON_DOWNLOADS=never
    export REPO_ROOT=$(git rev-parse --show-toplevel)
  '';

  git-hooks.hooks.treefmt = {
    enable = true;
    settings.formatters = [
      pkgs.nixfmt-rfc-style
    ];
  };
}
