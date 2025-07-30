{ ... }:

{
  cachix.enable = false;
  git-hooks.hooks = {
    trim-trailing-whitespace.enable = true;
    end-of-file-fixer.enable = true;
    check-yaml.enable = true; # Does not validate schema
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    actionlint.enable = true;
    trufflehog.enable = true;
  };
}
