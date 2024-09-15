{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.system.static-ostree;

  static-ostree-build = pkgs.callPackage ./static-ostree-build.nix { inherit config; };
in
{
  options = { };

  config = {
    system.build.static-ostree = static-ostree-build;

    meta.maintainers = [ lib.maintainers.msanft ];
  };
}
