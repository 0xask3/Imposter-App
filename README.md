# Imposter

Imposter is an offline party game for three or more people sharing one phone. Most players receive the same secret word. The imposter receives their role and, if hints are enabled, a one-word clue.

## What you need

- Git
- Flutter SDK that includes Dart **3.13.5 or later in the 3.x series** (`pubspec.yaml` requires `^3.13.5`)
- Android Studio with the Android SDK, SDK Platform-Tools, and Android SDK Command-line Tools
- Java 17. Android Studio's bundled Java runtime is suitable
- An Android phone with USB debugging enabled, or an Android emulator

This repository currently sets up Android as its build target. No API keys, account, or server are needed to run the game.

## Clone and set up

Clone the repository and move into its folder:

```sh
git clone https://github.com/0xask3/Imposter-App.git
cd Imposter-App
```

Check that Flutter can find the Android tools and accept the Android SDK licenses if prompted:

```sh
flutter doctor -v
flutter doctor --android-licenses
```

Download the Dart and Flutter packages:

```sh
flutter pub get
```

## Run on Android

Connect a phone with USB debugging enabled or start an emulator. List available devices:

```sh
flutter devices
```

Run on a specific device using the ID shown above:

```sh
flutter run -d <device-id>
```

If only one device is connected, you can use `flutter run` without `-d <device-id>`.

In VS Code, open the cloned `Imposter-App` folder, select an Android device from the device picker, then press **F5** or choose **Run > Start Debugging**.

## Build a debug APK

Create an APK for local testing:

```sh
flutter build apk --debug
```

The APK is written to:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Publish a production APK on GitHub

Pushing a version tag such as `v1.0.0` starts the Android release workflow. It builds a signed production APK and publishes it as an asset on a GitHub Release. The APK version name comes from the tag; the build number comes from the Actions run number. Release builds require the signing key configured below.

Configure signing once before creating the first release:

1. Generate a private Android upload keystore. Keep it somewhere safe and do not commit it:

   ```sh
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias imposter-upload
   ```

2. Convert it to Base64. In PowerShell, run this from the directory containing the keystore and copy the output:

   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard
   ```

3. In GitHub, open **Settings > Secrets and variables > Actions** and add these repository secrets:

   - `ANDROID_KEYSTORE_BASE64`: the copied Base64 value
   - `ANDROID_KEYSTORE_PASSWORD`: the keystore password
   - `ANDROID_KEY_ALIAS`: `imposter-upload` (or the alias you chose)
   - `ANDROID_KEY_PASSWORD`: the key password

Create and push a version tag to publish:

```sh
git tag v1.0.0
git push origin v1.0.0
```

The workflow attaches `Imposter-v1.0.0.apk` to the release. Keep using the same keystore for future updates so Android can install them over the existing app.

## Play the game

1. Add at least three players with unique names.
2. Choose the number of imposters, categories, and difficulty. The optional hint gives imposters a one-word clue.
3. Pass the phone around so each player can privately reveal their assignment.
4. Give clues, discuss, and vote together. Voting happens outside the app.
5. Reveal the imposter and secret word in the results screen.

The built-in catalog has 12 categories with 50 words each. The game works offline and stores recent word history on the device to reduce repeats.

## Check the project

Run the static analyzer and automated tests from the repository root:

```sh
flutter analyze
flutter test
```

## Project structure

```text
lib/
  application/       Game and setup state
  data/builtin/      Categories and built-in words
  data/local/        On-device word history
  domain/            Game rules, models, and validation
  presentation/      Screens, routes, and visual components
test/                Unit and widget tests
android/             Android app and launcher resources
docs/                Product, game, privacy, and architecture notes
```
