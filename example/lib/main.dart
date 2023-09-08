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
          child: ReclaimSwiggy(
  requestedProofs: [
    SwiggyRequestedProof(
      url: 'https://www.swiggy.com/dapi/order/all?order_id=',
      loginUrl: 'https://www.swiggy.com/auth',
      loginCookies: ['_session_tid'],
    ),
  ],
  title: "Swiggy",
  subTitle: "Prove that you are a swiggy user",
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
