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

## Build an APK

Create a debug APK:

```sh
flutter build apk --debug
```

The APK is written to:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

The project currently uses the debug signing key for Android release builds. Configure a private release keystore before distributing a release APK or publishing to an app store.

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
