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
      itemCount: 1,
      itemBuilder: (BuildContext context, int index) {
        return Center(
          child: ReclaimSwiggyEqual(
  requestedProofs: [
    SwiggyEqualRequestedProof(
      url: 'https://www.swiggy.com/dapi/order/all?order_id=',
      loginUrl: 'https://www.swiggy.com/auth',
      loginCookies: ['_session_tid'],
    ),
  ],
  title: "Swiggy",
  subTitle: "• Fetch your Order history",
  cta: "Fetch",
  onClaimStateChange:(claimState){
    // claimState can be 'initiating', 'creating', 'done'
    // Hide ReclaimSwiggyEqual Widget on claimState === 'initiating' and show fetching animation
    print(claimState);
  },
  onSuccess: (proofs) {
    print('proofs: $proofs');
    // Show a success modal or bottom sheet
  },
  onFail: (Exception e) {
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