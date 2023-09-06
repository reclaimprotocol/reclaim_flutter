![Reclaim Logo](https://reclaim-react-native-sdk.s3.ap-south-1.amazonaws.com/Logomark.png)
# Reclaim React Native SDK

This is a comprehensive guide to get you started with the `reclaim_flutter` SDK in your React Native project. 

`reclaim_flutter` SDK provides a way to let your users import data from other websites into your app in a secure, privacy preserving manner using zero knowledge proofs right in your React Native Application.

---

# Installation Guide for `reclaim_flutter`

You can use Dart or Flutter to install the `reclaim_flutter` package.

## Installation with Dart:

Run the following command in your terminal:

```bash
$ dart pub add reclaim_flutter
```

## Installation with Flutter:

Run the following command in your terminal:

```bash
$ flutter pub add reclaim_flutter
```

Using any of the above commands adds a line to your package's `pubspec.yaml` (and also runs an implicit `dart pub get`):

```yaml
dependencies:
  reclaim_flutter: any
```
If your IDE supports `dart pub get` or `flutter pub get`, you can use that as an alternative. Be sure to consult the documentation specific to your editor for details. 

## Importing the Package 

After installing the package, you can now import and use it in your Dart code:

```dart
import 'package:reclaim_flutter/reclaim_flutter.dart';
```
You are now ready to use the `reclaim_flutter` in your Dart project.