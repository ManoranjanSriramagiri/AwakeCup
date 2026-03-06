# AwakeCup

Menu bar app (macOS) that keeps your Mac awake — similar to Caffeine.

## What it does

- Adds a menu bar icon (cup).  
- Click to **Keep Awake / Disable**.
- Optionally enable for a **fixed duration** (5m, 15m, 30m, 1h, 2h) or **Indefinitely**.
- Optional **Launch at login** toggle.

Under the hood, AwakeCup uses macOS power-management assertions:

- `PreventUserIdleSystemSleep`
- `PreventUserIdleDisplaySleep`

## Requirements

- macOS **13.0+** (uses `MenuBarExtra`)
- Xcode 15+ recommended

## Build & run

This repo uses **XcodeGen** so we don’t commit an `.xcodeproj`.

1. Install XcodeGen:

```bash
brew install xcodegen
```

2. Generate the Xcode project:

```bash
cd AwakeCup
xcodegen generate
```

3. Open `AwakeCup.xcodeproj` in Xcode and Run.

## Build & run without Xcode (Command Line Tools only)

If you don’t have Xcode installed, you can still build a runnable `.app` bundle using the included scripts.

Build the app:

```bash
cd ~/AwakeCup
bash scripts/build_app_clt.sh
```

Launch it:

```bash
open "build-clt/AwakeCup.app"
```

## Build a standalone `.app` (and launch like a normal app)

1. Generate the project (if you haven’t already):

```bash
cd ~/AwakeCup
xcodegen generate
```

2. Build a Release `.app`:

```bash
cd ~/AwakeCup
xcodebuild -project AwakeCup.xcodeproj -scheme AwakeCup -configuration Release -derivedDataPath build clean build
```

3. The app will be at:

```bash
open "build/Build/Products/Release/AwakeCup.app"
```

4. To “install” it, copy it into `/Applications` and launch it:

```bash
cp -R "build/Build/Products/Release/AwakeCup.app" /Applications/
open /Applications/AwakeCup.app
```

## Create a `.dmg`

### Option A: Simple DMG (built-in `hdiutil`)

After you’ve built `AwakeCup.app` (see above):

```bash
cd ~/AwakeCup
rm -rf dist && mkdir -p dist
cp -R "build/Build/Products/Release/AwakeCup.app" dist/
hdiutil create -volname "AwakeCup" -srcfolder dist -ov -format UDZO "AwakeCup.dmg"
```

You can then distribute `AwakeCup.dmg`. Users drag `AwakeCup.app` into `/Applications`.

### Option A (no Xcode): DMG via included script

```bash
cd ~/AwakeCup
bash scripts/make_dmg.sh
```

If you see `hdiutil: create failed - Device not configured`, you’re likely running in a restricted/sandboxed environment. Run the same command from your normal macOS Terminal session.

### Option B: Nicer “drag to Applications” DMG (optional)

If you want a DMG with an `/Applications` shortcut and a nicer layout, you can use `create-dmg`:

```bash
brew install create-dmg
cd ~/AwakeCup
create-dmg --volname "AwakeCup" --app-drop-link 425 120 "AwakeCup.dmg" "dist/AwakeCup.app"
```

## Gatekeeper note (codesigning)

If you share the app outside your own Mac, macOS may warn because it’s not signed/notarized. For personal use, you can typically allow it via **System Settings → Privacy & Security** after first launch.

## Notes

- The app is a “menu bar only” app (no Dock icon) via `LSUIElement` in `AwakeCup/Info.plist`.
- If “Launch at login” fails on your macOS version/settings, the app will show an error message in the menu.

## License

MIT. See `LICENSE`.
