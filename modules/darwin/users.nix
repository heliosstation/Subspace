{subvars, ...}: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${subvars.username}" = {
    home = "/Users/${subvars.username}";
  };
}
