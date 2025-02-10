{lib, ...}: let
  envExtra = ''
    export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
  '';
in {
  programs.bash = {
    enable = true;
    bashrcExtra = lib.mkAfter envExtra;
  };
  programs.zsh = {
    enable = true;
    inherit envExtra;
  };
}
