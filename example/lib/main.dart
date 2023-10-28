import 'package:flutter/material.dart';
import 'package:reclaim_flutter/reclaim_flutter.dart';
void main() {
  runApp(const MainApp());
}

// Init a GlobalKey and pass it to ReclaimSwiggyEqual widget
final swiggyEqualKey = GlobalKey<ReclaimSwiggyEqualState>();

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
                  ReclaimSwiggyEqual(
                    key: swiggyEqualKey,
                    requestedProofs: [
                      SwiggyEqualRequestedProof(
                        url: 'https://www.swiggy.com/dapi/order/all?order_id=',
                        loginUrl: 'https://www.swiggy.com/auth',
                        loginCookies: ['_session_tid'],
                      ),
                    ],
                    title: "Swiggy",
                    subTitle: "Prove that you are a swiggy user",
                    cta: "Prove",
                    onClaimStateChange: (claimState) {
                      // claimState can be 'initiating', 'creating', 'done'
                      // Hide ReclaimSwiggyEqual Widget on claimState === 'initiating' and show fetching animation
                      print(claimState);
                    },
                    onSuccess: (proofs) {
											// proofs contains a list of proof
                      print('proofs: $proofs');
                      // Show a success modal or bottom sheet
                    },
                    onFail: (Exception e) {
                      print('Error: $e');
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Custom Trigger'),
                    onPressed: () {
											//The trigger can be called from anywhere
                      swiggyEqualKey.currentState?.triggerOpenWebView();
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