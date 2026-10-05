> **REMINDER: Check https://github.com/fluttercommunity/plus_plugins/issues/3944 periodically.**
> `device_info_plus` (transitive, via `vibration` -> `vibration_platform_interface`) still applies the Kotlin Gradle Plugin, which blocks setting `android.builtInKotlin=true` in `android/gradle.properties`. Once that issue is resolved and a fixed release is available, upgrade the plugin and finish the Built-in Kotlin migration: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers

## Flutter SDK

The Flutter version is pinned in `.fvmrc` and managed with [fvm](https://fvm.app). Always run Flutter/Dart via fvm, exactly as you would locally — e.g. `fvm flutter pub get`, `fvm flutter analyze`, `fvm flutter test`, `fvm dart run ...`. Never call bare `flutter`/`dart`. In cloud sessions, the environment setup script (reference copy: `.claude/cloud-setup.sh`) pre-installs fvm and the SDK into the cached image, and `.claude/hooks/session-start.sh` makes sure the version in `.fvmrc` is installed and on PATH.
