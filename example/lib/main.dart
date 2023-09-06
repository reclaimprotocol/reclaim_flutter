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
      url: 'https://www.amazon.in/',
      loginUrl: 'https://www.amazon.in/ap/signin?openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.amazon.in%2F%3Fref_%3Dnav_custrec_signin&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.assoc_handle=inflex&openid.mode=checkid_setup&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0',
      loginCookies: ['x-acbin', 'at-acbin', 'sess-at-acbin', 'sst-acbin', 'i18n-prefs', 'lc-acbin'],
      responseSelections: [
        ResponseSelection(
          responseMatch: 'nav-prime-1',
        ),
      ],
    ),
  ],
  title: "Amazon Prime",
  subTitle: "Prove you have an Amazon Prime membership",
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
