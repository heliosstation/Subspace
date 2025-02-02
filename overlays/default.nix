args:
# Import and execute all overlay files in the current directory, passing the given arguments.
builtins.map
  (f: (import (./. + "/${f}") args)) # Import each overlay file dynamically.

# Filter out files that should be ignored (e.g., default.nix and README.md) and get the list of overlay files.
(builtins.filter 
  (f:
    f != "default.nix"  # Exclude default.nix to avoid recursive imports.
    && f != "README.md" # Exclude README.md since it's not an overlay.
  )
  (builtins.attrNames (builtins.readDir ./.) # Get all file names in the current directory.
  )
)