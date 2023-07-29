{ pkgs, ... }: {
  environment.systemPackages = with pkgs.unstable; [
    chromium
  ];

  programs = {
    chromium = {
      enable = true;
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # BitWarden
        "fnaicdffflnofjppbagibeoednhnbjhg" # Floccus Bookmark Sync
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # UBlock Origin
        "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      ];
      extraOpts = {
        "AutofillAddressEnabled" = false;
        "AutofillCreditCardEnabled" = false;
        "BuiltInDnsClientEnabled" = false;
        "DeviceMetricsReportingEnabled" = true;
        "ReportDeviceCrashReportInfo" = false;
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [
          "en-US"
        ];
        "VoiceInteractionHotwordEnabled" = false;
      };
    };
  };
}
