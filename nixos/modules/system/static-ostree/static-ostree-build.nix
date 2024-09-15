{
  config,
  pkgs,
  ...
}:
let
  # TODO(msanft): handle deps
  allActivationScripts = pkgs.lib.concatMapStrings (script: ''
    ${script.text}
  '') (builtins.attrValues config.system.activationScripts);
in
pkgs.runCommand "static-ostree" { } ''
  chroot $out
  ${allActivationScripts}
''
