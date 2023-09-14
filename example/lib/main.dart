import 'package:flutter/material.dart';
import 'package:reclaim_flutter/reclaim_flutter.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              subTitle: "Prove your Swiggy Home Address",
              cta: "Prove",
              onSuccess: (proofs) {
                print(proofs);
                 Future.delayed(Duration(seconds: 0)).then((val) {
showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
  ),
  builder: (context) => Container(
    color: Colors.transparent, // Essential to make background color transparent
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 60,
          ),
          const SizedBox(height: 15.0),
          const Text(
            'Successfully Verified Address!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30.0),
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder( 
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                jsonDecode(jsonDecode(proofs['claimData']['parameters'])['userData'])['data']['orders'][0]['delivery_address']['flat_no'] + jsonDecode(jsonDecode(proofs['claimData']['parameters'])['userData'])['data']['orders'][0]['delivery_address']['address'],
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
           const SizedBox(height: 30.0),
          TextButton.icon(
            style: TextButton.styleFrom(
              primary: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
            label: const Text(
              'Close',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
              
                 });
              },
              onFail: (Exception e) {
                // do something
                Future.delayed(Duration(seconds: 0)).then((val) {

                showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text("Successfully Verified Address",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green, fontSize: 20.0)),
                  SizedBox(
                    height: 20, // You can adjust the height as per your need
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[300],
                    child: Text("123 St, ABC City",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 16.0)), // Address with styling
                  ),
                ],
              ),
            ),
          );
    // Your logic here 
  });

                print('Error: $e');
              },
            ),
          );
        },
      ),
    );
  }
}