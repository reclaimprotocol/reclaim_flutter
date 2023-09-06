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
