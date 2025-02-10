{pkgs, ...}:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#  Incomplete list of macOS `defaults` commands :
#    https://macos-defaults.com
#
###################################################################################
{
  # Enable sudo authentication with Touch ID.
  security.pam.enableSudoTouchIdAuth = true;

  time.timeZone = "America/Los_Angeles";

  system = {
    # activationScripts run during system boot or when executing `nixos-rebuild` or `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # `activateSettings -u` reloads settings from the database and applies them to the current session,
      # eliminating the need to log out and back in for changes to take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      menuExtraClock.Show24Hour = true;
      menuExtraClock.ShowSeconds = true;

      dock = {
        autohide = true;
        show-recents = false;
        # Do not automatically rearrange spaces based on most recent use
        mru-spaces = false;
        # Group windows by application in Mission Control’s Exposé
        expose-group-apps = false;
      };

      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;

        FXEnableExtensionChangeWarning = false;
        # When performing a search, search the current folder by default
        FXDefaultSearchScope = "SCcf";
        # List view
        FXPreferredViewStyle = "Nlsv";

        QuitMenuItem = true;

        ShowPathbar = true;
        ShowStatusBar = true;
        ShowHardDrivesOnDesktop = true;
        ShowExternalHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;

        _FXSortFoldersFirst = true;
        _FXShowPosixPathInTitle = true;
      };

      trackpad = {
        # Enable tap to click
        Clicking = true;
        # Enable two finger right click
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
      };

      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      screencapture = {
        include-date = true;
        location = "~/Desktop/ScreenCaptures";
        type = "png";
      };

      spaces = {
        # One space spans across all physical displays
        spans-displays = false;
      };

      # customize macOS
      NSGlobalDomain = {
        # Enable natural scrolling
        "com.apple.swipescrolldirection" = true;
        "com.apple.sound.beep.feedback" = 0;

        # Dark Mode
        AppleInterfaceStyle = "Dark";
        # Mode 3 enables full keyboard control.
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = true;
        AppleSpacesSwitchOnActivate = false;

        # If you press and hold certain keyboard keys when in a text area, the key’s character begins to repeat. F
        # For example, the Delete key continues to remove text for as long as you hold it down.
        # This sets how long you must hold down the key before it starts repeating.
        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        # Sets how fast it repeats once it starts.
        # Normal minimum is 2 (30 ms), maximum is 120 (1800 ms)
        KeyRepeat = 3;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;

        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
      };

      WindowManager = {
        EnableStandardClickToShowDesktop = true;
        StandardHideDesktopIcons = false;
        HideDesktop = false;
        StageManagerHideWidgets = false;
        StandardHideWidgets = false;
      };

      # Customize settings that are not directly supported by nix-darwin.
      # For an incomplete list of macOS `defaults` commands, see:
      #   https://github.com/yannbertrand/macos-defaults
      CustomUserPreferences = {
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;

        "com.apple.Safari" = {
          ShowFullURLInSmartSearchField = true;
          IncludeInternalDebugMenu = true;
          IncludeDevelopMenu = true;
          WarnAboutFraudulentWebsites = true;
        };

        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          # Check for software updates daily, not just once per week
          ScheduleFrequency = 1;
          # Download newly available updates in background
          AutomaticDownload = 1;
          # Install System data files & security updates
          CriticalUpdateInstall = 1;
        };

        # Turn on app auto-update
        "com.apple.commerce".AutoUpdate = true;
      };

      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = true;
      };
    };
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      font-awesome

      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  };
}
