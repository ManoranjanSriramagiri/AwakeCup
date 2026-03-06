# Contributing

Thanks for wanting to contribute!

## Development setup

- Install Xcode (recommended) and XcodeGen:

```bash
brew install xcodegen
```

- Generate the project and build:

```bash
cd AwakeCup
xcodegen generate
xcodebuild -project AwakeCup.xcodeproj -scheme AwakeCup -configuration Debug build
```

## Guidelines

- Keep the app lightweight (menu bar first, minimal UI).
- Prefer standard macOS APIs (IOKit assertions) over hacks.
- Keep the README updated when behavior changes.

## Submitting changes

1. Fork the repo and create a feature branch.
2. Make changes with a clear commit message.
3. Open a PR with:
   - What changed and why
   - How you tested

