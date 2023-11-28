import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:reclaim_flutter/providers/http/types.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:web3dart/crypto.dart';
import 'dart:math';
import 'package:web3dart/web3dart.dart';
import 'dart:convert';

class HiddenWebViewScreen extends StatefulWidget {
  final BuildContext context;
  final List<RequestedProof> requestedProofs;
  final Function(String webViewData) onModification;
  final Function(String status) onStatusChange;
  final Function(Map<String, dynamic> proofs) onSuccess;
  final Function(Exception e) onFail;
  final String cookieStr;
  final dynamic parseResult;

  static void _defaultOnStatusChange(String input) {}

  const HiddenWebViewScreen({
    Key? key,
    required this.context,
    required this.requestedProofs,
    required this.onModification,
    required this.onSuccess,
    required this.onFail,
    this.onStatusChange = _defaultOnStatusChange,
    required this.cookieStr,
    required this.parseResult,
  }) : super(key: key);

  @override
  _HiddenWebViewScreenState createState() => _HiddenWebViewScreenState();
}

class _HiddenWebViewScreenState extends State<HiddenWebViewScreen> {
  var controller = WebViewController();
  final cookieManager = WebviewCookieManager();

  bool isPageLoaded = false;

  @override
  void initState() {
    super.initState();
    controller
      ..addJavaScriptChannel(
        'Login',
        onMessageReceived: (JavaScriptMessage message) {
          controller.runJavaScript('''Claim.postMessage("Init")''');
        },
      )
      ..addJavaScriptChannel(
        'Check',
        onMessageReceived: (JavaScriptMessage message) {
          var response = jsonDecode(message.message);
          if (response["type"] == "createClaimStep") {
            if (response["step"]["name"] == "creating") {
              widget.onModification('Creating Claim');
            }
            if (response["step"]["name"] == "witness-done") {
              widget.onModification('Claim Created Successfully');
            }
          }
          if (response["type"] == "createClaimDone") {
            response['response']['extractedParameterValues'] =
                widget.parseResult['params'];
            widget.onSuccess(response["response"]);
          }

          if (response["type"] == "error") {
            widget.onModification('Claim Creation Failed');
            widget.onFail(Exception("${response["data"]["message"]}"));
          }
        },
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onProgress: (int progress) {
          //  print("Loading ${progress}%");
        }, onPageFinished: (String url) async {
          if (!isPageLoaded && url == "https://sdk-rpc.reclaimprotocol.org/") {
            isPageLoaded = true;
            var random = Random.secure();
            EthPrivateKey priKey = EthPrivateKey.createRandom(random);
            String privateKey = bytesToHex(priKey.privateKey, include0x: true);
            var diff = privateKey.length - 66;
            if (diff > 0) {
              privateKey = '0x${privateKey.substring(2 + diff)}';
            }

            Map<String, dynamic> req = {
              "channel": "Check",
              "module": "witness-sdk",
              "id": "123",
              "type": "createClaim",
              "request": {
                "name": "http",
                "params": {
                  "url": widget.requestedProofs[0].url,
                  "method": "GET",
                  "responseSelections": [
                    {
                      "responseMatch": widget.parseResult["result"],
                    }
                  ]
                },
                "secretParams": {
                  "cookieStr": widget.cookieStr,
                },
                "ownerPrivateKey": privateKey,
              }
            };

            controller.runJavaScript('''postMessage(${jsonEncode(req)})''');
            return;
          }
        }),
      )
      ..loadRequest(Uri.parse("https://sdk-rpc.reclaimprotocol.org/"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WebViewWidget(controller: controller),
    );
  }
}
