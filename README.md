# Reclaim Flutter SDK

![Reclaim Logo](https://reclaim-react-native-sdk.s3.ap-south-1.amazonaws.com/Logomark.png)

Use the `reclaim_flutter` SDK to enable your users import data securely from other websites into your Flutter application in a privacy-preserving manner using zero-knowledge proofs.

## 📚 Table of Contents
1. [Installation](#installation)
2. [Usage](#usage)
3. [Example](#example)

## 💻 Installation <a name="installation"></a>

You can add `reclaim_flutter` to your Flutter project using Dart or Flutter.

### Dart

Run the following command in your terminal:

```bash
$ dart pub add reclaim_flutter
```

### Flutter

Alternatively, you can use Flutter to install the package:

```bash
$ flutter pub add reclaim_flutter
```

Running the command will add this line to your `pubspec.yaml`:

```yaml
dependencies:
  reclaim_flutter: ^0.0.1
```

After installation, you can import the package in your Dart code:

```dart
import 'package:reclaim_flutter/reclaim_flutter.dart';
```

## 🚀 Usage <a name="usage"></a>

Once the package is installed, you can start using `ReclaimHttps` in your application as follows:

```dart
import 'package:flutter/material.dart';
import 'package:reclaim_flutter/reclaim_flutter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          itemCount: 1, // Only one item
          itemBuilder: (BuildContext context, int index) {
            return Center(
              child: ReclaimHttps(
                requestedProofs: [
                  RequestedProof(
                    url: 'https://bookface.ycombinator.com/home',
                    loginUrl: 'https://bookface.ycombinator.com/home',
                    loginCookies: ['_sso.key'],
                    responseSelections: [
                      ResponseSelection(
                        responseMatch: '\{\"id\":{{YC_USER_ID}},.*?waas_admin.*?:{.*?}.*?:\\{.*?}.*?(?:full_name|first_name).*?}',
                      ),
                    ],
                  ),
                ],
                title: "YC Login",
                subTitle: "Prove you have a YC Login",
                cta: "Prove",
                onSuccess: (proofs) {
                  // do something
                  print('proofs: $proofs');
                },
                onFail: (Exception e) {
                  // do something
                  print('Error: $e');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
```

## 📁 Example <a name="example"></a>

We have included an example project in the root directory to implement a https provider. You can find this [here](https://github.com/reclaimprotocol/reclaim_flutter/tree/main/example).

Running this example will showcase how `reclaim_flutter` can be implemented in a Flutter project. Simply clone the repository, navigate to the `example` folder, install the dependencies, and run the project.