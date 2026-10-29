# navicat-trial-reset

Resets the Navicat Premium trial on macOS and Windows. Each script is a single file with no external dependencies. For learning purposes only — please support the official product: [Navicat Premium](https://www.navicat.com/download/navicat-premium).

## Features

- Matches storage-structure patterns instead of hardcoding trial-record keys (the Windows script keeps a few fixed names for older versions)
- Removes trial state only; database connections, query history and UI settings are preserved
- No admin/sudo rights and no reboot required

## Usage

### macOS

- Double-click `mac/reset_navicat_universal.command`
- Or run `sh mac/reset_navicat_universal.sh [app display name]` (defaults to `Navicat Premium`)

If Gatekeeper blocks the first double-click, right-click → Open → Open again.

### Windows

Double-click `windows/reset_navicat_universal.bat`.

The script quits all Navicat processes before cleaning, so save your work first. The next launch starts a fresh 14-day trial.

## What gets reset

### macOS

- `~/Library/Preferences/com.navicat.NavicatPremium.plist`: remove all top-level 32-char uppercase-hex keys (trial record primary/backup, state snapshot)
- `~/Library/Application Support/PremiumSoft CyberTech/Navicat CC/Navicat Premium/`: remove hidden `.<32hex>` files that are exactly 32 bytes
- kill cfprefsd first so the prefs cache cannot write back stale values

### Windows

- `HKCU\Software\Classes\CLSID` (incl. WOW6432Node): remove whole subkeys that have an `Info` value, or whose `ShellFolder` data points to Navicat / PremiumSoft (where the 16/17/18 trial clock lives; Navicat rebuilds them on next launch)
- `HKCU\Software\PremiumSoft\NavicatPremium`: clear all values of `Registration<digit>` subkeys (PreTrial trial record); remove 32-hex subkeys (v12~15); remove the `Update` subkey (update-check cache only)
- `%APPDATA%\PremiumSoft CyberTech\Navicat CC\Navicat Premium`: remove hidden `.<32hex>` files that are exactly 32 bytes

## Verified

| Navicat version | Result |
|---|---|
| 18.0.3 | verified on macOS and Windows 10 |

Other versions are not individually verified; the scripts work from storage-structure patterns and should usually work — add a row after verifying. If a reset does not stick, open an issue.

## Acknowledgments

The idea comes from [pretend-m/navicat_for_mac_reset](https://github.com/pretend-m/navicat_for_mac_reset).

## License

[MIT](LICENSE)
