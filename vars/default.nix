{lib}: {
  username = "helios";
  userfullname = "Suraj Bajirao Malode";
  useremail = "helios@heliosstation.io";
  networking = import ./networking.nix {inherit lib;};

  # See: https://mynixos.com/nixpkgs/option/users.users.%3Cname%3E.initialHashedPassword
  # We have to use initialHashedPassword here when using tmpfs for /. Generated using:
  # nix shell nixpkgs#mkpasswd -- -m scrypt
  initialHashedPassword = "$7$CU..../....em4HSt9i1.P4RjcB2G2DL/$mXDTNztPWTIJ30GlKHHSDsxvK/0szy5YtWu6Jg.xTI3";
  # Public Keys that can be used to login to all my PCs, Macbooks, and servers.
  #
  # Since its authority is so large, we must strengthen its security:
  # 1. The corresponding private key must be:
  #    1. Generated locally on every trusted client via:
  #      ```bash
  #      # KDF: bcrypt with 256 rounds, takes 2s on Apple M2):
  #      # Passphrase: digits + letters + symbols, 12+ chars
  #      ssh-keygen -t ed25519 -a 256 -C "<user>s@<hostname>" -f ~/.ssh/<user>s@<hostname>`
  #      ```
  #    2. Never leave the device and never sent over the network.
  # 2. Or just use hardware security keys like Yubikey/CanoKey.
  sshAuthorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINjdINJKcWzT2mmfT8q4+hKEZEpTtBcqd9Vb3t1V0SIt helios@dhd"
  ];
}
