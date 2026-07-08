fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios bump_build

```sh
[bundle exec] fastlane ios bump_build
```

Bump the Flutter build number in pubspec.yaml (+1)

### ios bump_version

```sh
[bundle exec] fastlane ios bump_version
```

Bump marketing version in pubspec.yaml (major|minor|patch)

### ios build

```sh
[bundle exec] fastlane ios build
```

Build a release IPA with Flutter

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight (auto-bumps build number)

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Upload the latest built IPA to TestFlight (skip build)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
