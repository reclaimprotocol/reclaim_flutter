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
          child: ReclaimOnemgEqual(
  requestedProofs: [
    OnemgEqualRequestedProof(
      url: 'https://www.1mg.com/labs_api/v4/bookings',
      loginUrl: 'https://www.1mg.com/my-account',
      loginCookies: ['session'],
    ),
  ],
  title: "Tata 1mg",
  subTitle: "•  Fetch your health records",
  cta: "Fetch",
  onClaimStateChange:(claimState){
    // claimState can be 'initiating', 'creating', 'done'
    // Hide ReclaimOnemgEqual Widget on claimState === 'initiating' and show fetching animation
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