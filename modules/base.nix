{
  config,
  pkgs,
  subvars,
  ...
} @ args: {
  nixpkgs.overlays = import ../overlays args;

  # auto upgrade nix to the unstable version
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/tools/package-management/nix/default.nix#L284
  nix.package = pkgs.nixVersions.latest;

  # For security reasons, do not load neovim's user config
  # since EDITOR may be used to edit some critical files
  environment.variables.EDITOR = "nvim --clean";

  environment.systemPackages = with pkgs; [
    # Core tools
    fastfetch
    neovim
    just
    git
    git-lfs

    # Archives
    zip
    xz
    zstd
    unzipNLS
    p7zip

    # Text Processing
    # Docs: https://github.com/learnbyexample/Command-line-text-processing
    gnugrep
    gnused
    gawk
    jq

    # Networking Tools
    # Network disagnostic Tool
    mtr
    iperf3
    dnsutils
    ldns
    wget
    curl
    aria2
    socat
    nmap
    ipcalc

    # Miscellaneous
    file
    findutils
    which
    tree
    gnutar
    rsync
  ];

  users.users.${subvars.username} = {
    description = subvars.userfullname;
    # Public Keys that can be used to login to all my PCs, Macbooks, and servers.
    #
    # Since its authority is so large, we must strengthen its security:
    # 1. The corresponding private key must be:
    #    1. Generated locally on every trusted client via:
    #      ```bash
    #      # KDF: bcrypt with 256 rounds, takes 2s on Apple M2):
    #      # Passphrase: digits + letters + symbols, 12+ chars
    #      ssh-keygen -t ed25519 -a 256 -C "dhd@xxx" -f ~/.ssh/xxx`
    #      ```
    #    2. Never leave the device and never sent over the network.
    # 2. Or just use hardware security keys like Yubikey/CanoKey.
    # TODO: Setup hardware Key
    openssh.authorizedKeys.keys = subvars.sshAuthorizedKeys;
  };

  nix.settings = {
    # Enable flakes globally
    experimental-features = ["nix-command" "flakes"];

    # Given the users in this list the right to specify additional substituters via:
    #   1. `nixConfig.substituers` in `flake.nix`
    #   2. command line args `--options substituers http://xxx`
    trusted-users = [subvars.username];

    # Substituers that will be considered before the official ones (https://cache.nixos.org)
    substituters = [
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      # From: https://app.cachix.org/cache/nix-community
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    builders-use-substitutes = true;
  };
}
