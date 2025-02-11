{subsecrets, ...}: {
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };
}
