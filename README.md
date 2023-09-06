# Reclaim Flutter SDK

![Reclaim Logo](https://reclaim-react-native-sdk.s3.ap-south-1.amazonaws.com/Logomark.png)

With `reclaim_flutter` SDK, allow your users to import data from other websites into your app in a secure, privacy-preserving manner using zero-knowledge proofs, right inside your Flutter application.

---

## 📚 Table of Contents
1. [Installation](#installation)
2. [Usage](#usage)

---

## 💻 Installation <a name="installation"></a>

Start by adding `reclaim_flutter` to your Flutter project.

### Dart

Run this command in your terminal:

```bash
$ dart pub add reclaim_flutter
```

### Flutter

Alternatively, you can use Flutter to add the package:

```bash
$ flutter pub add reclaim_flutter
```
After running the command, it should add the following line to your `pubspec.yaml`:

```yaml
dependencies:
  reclaim_flutter: ^0.0.1
```

Then in your Dart code, import the package:

```dart
import 'package:reclaim_flutter/reclaim_flutter.dart';
```

## 🚀 Usage <a name="usage"></a>

After installing the package, you can now use ReclaimHttps in your app as follows:

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

ReclaimHttps accepts the following properties:

- `url`: The URL from where the information is to be extracted. Typically, this webpage contains the user's data.
- `loginUrl`: The URL to which the user can log in to access the information. In case authentication is needed to access the data, the user will be redirected here for login.
- `loginCookies`: An array of cookie names for authentication. If the webpage uses cookies for authentication, you can specify the cookies here. These will be passed along with the request to the url.
- `responseMatch`: A regular expression used to extract specific information from the webpage. If you need to extract only a specific part of the information from the webpage, a regex pattern can be specified here.
- `context`: Context message for the proof request (Optional)
- `title`: The name of your application.
- `subTitle`: The sub title of the component button, usually a short description about the claim.
- `cta`: The title of cta button.
- `onSuccess`: A Function that returns proofs after successful proof generation.
- `onFail`: A Function that returns Error when the proof generation fails.