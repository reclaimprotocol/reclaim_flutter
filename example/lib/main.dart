import 'package:flutter/material.dart';
import 'package:reclaim_flutter/reclaim_flutter.dart';

void main() {
  runApp(const MainApp());
}

// Init a GlobalKey and pass it to ReclaimHttps widget
final httpEqualKey = GlobalKey<ReclaimHttpsState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Center(
              child: Column(
                children: [
                  ReclaimHttps(
                    key: httpEqualKey,
                    requestedProofs: [
                      RequestedProof(
                        url: 'https://bookface.ycombinator.com/home',
                        loginUrl: 'https://bookface.ycombinator.com/home',
                        loginCookies: ['_sso.key'],
                        responseSelections: [
                          ResponseSelection(
                            responseMatch:
                                '{&quot;id&quot;:{{YC_USER_ID}},.*?waas_admin.*?:{.*?}.*?:\\{.*?}.*?(?:full_name|first_name).*?}',
                          ),
                        ],
                      ),
                    ],
                    title: "YC Login",
                    subTitle: "Prove you have a YC Login",
                    cta: "Prove",
                    onStatusChange: (status) =>
                        print('Status changed to : $status'),
                    onSuccess: (proofs) {
                      // do something
                      print('proofs: $proofs');
                    },
                    onFail: (Exception e) {
                      // do something
                      print('Error: $e');
                    },
                    showShell: true,
                    shellStyles: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2.0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: const Text('Custom Trigger'),
                    onPressed: () {
                      //The trigger can be called from anywhere
                      httpEqualKey.currentState?.triggerOpenWebView();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
