library reclaim_flutter;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:wallet/wallet.dart' as wallet;
import 'package:flutter_ethers/flutter_ethers.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class SwiggyRequestedProof {
  final String url;
  final String loginUrl;
  final List<String> loginCookies;

  SwiggyRequestedProof({
    required this.url,
    required this.loginUrl,
    required this.loginCookies,
  });
}

// ignore: must_be_immutable
class ReclaimSwiggy extends StatefulWidget {
  final List<SwiggyRequestedProof> requestedProofs;
  final String title;
  final String subTitle;
  String cta;
  final Function(Map<String, dynamic> proofs) onSuccess;
  final Function(Exception e) onFail;

  ReclaimSwiggy({
    Key? key,
    required this.requestedProofs,
    required this.title,
    required this.subTitle,
    required this.cta,
    required this.onSuccess,
    required this.onFail,
  }) : super(key: key);

  @override
  _ReclaimSwiggyState createState() => _ReclaimSwiggyState();
}

class _ReclaimSwiggyState extends State<ReclaimSwiggy> {
  String _claimState = "";

  final cookieManager = WebviewCookieManager();
  String? cookieStr;
  dynamic parseResult;
  late Timer timer;
  late Timer webviewTimer;
  bool webviewOneTimeRun = false;

  // Create WebViewController
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller here
    controller = WebViewController();
    configureController();
  }

  void configureController() {
    // Configure WebViewController

    controller
      ..addJavaScriptChannel(
        'Check',
        onMessageReceived: (JavaScriptMessage message) {
          var response = jsonDecode(message.message);

          if (response["type"] == "createClaimStep") {
            if (response["step"]["name"] == "creating") {
              setState(() {
                _claimState = 'Creating Claim';
              });
            }
            if (response["step"]["name"] == "witness-done") {
              setState(() {
                _claimState = 'Claim Created Successfully';
              });
            }
          }
          if (response["type"] == "createClaimDone") {
            widget.onSuccess(response["response"]);
          }

          if (response["type"] == "error") {
            setState(() {
              _claimState = 'Claim Creation Failed';
            });
            widget.onFail(Exception("${response["data"]["message"]}"));
          }
        },
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageFinished: (String url) async {
            webviewTimer =
                Timer.periodic(const Duration(seconds: 2), (Timer t) async {
              if (webviewOneTimeRun) {
                return;
              }

              if (cookieStr != null && parseResult != null) {
                final mnemonic = wallet.generateMnemonic();
                final walletMnemonic = Wallet.fromMnemonic(mnemonic.join(' '));
                Map<String, dynamic> jsonObject = jsonDecode(parseResult);
                jsonObject.remove("csrfToken");
                String updatedJsonString = jsonEncode(jsonObject);

                Map<String, dynamic> req = {
                  "channel": "Check",
                  "module": "witness-sdk",
                  "id": "123",
                  "type": "createClaim",
                  "request": {
                    "name": "swiggy-equal",
                    "params": {"userData": updatedJsonString},
                    "secretParams": {
                      "cookieStr": cookieStr,
                    },
                    "ownerPrivateKey": walletMnemonic.privateKey,
                  }
                };

                setState(() {
                  _claimState = 'Please wait, Initiating Claim Creation';
                });

                controller.runJavaScript('''postMessage(${jsonEncode(req)})''');
                webviewTimer.cancel();
                webviewOneTimeRun = true;
              }
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://sdk-rpc.reclaimprotocol.org/'));
  }

  void _openWebView(
      BuildContext context,
      String url,
      List<SwiggyRequestedProof> requestedProofs,
      Function(Map<String, dynamic> proofs) onSuccess,
      Function(Exception e) onFail) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SwiggyWebViewScreen(
            context: context,
            url: Uri.parse(url),
            requestedProofs: requestedProofs,
            onModification: (webViewData) {
              setState(() {
                _claimState = webViewData;
              });
            },
            onParseResult: (parseData) {
              setState(() {
                parseResult = parseData;
              });
            },
            onCookieStrData: (cookieStrData) {
              setState(() {
                cookieStr = cookieStrData;
              });
            },
            onSuccess: onSuccess,
            onFail: onFail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            width: 0, height: 0, child: WebViewWidget(controller: controller)),
        Container(
          width: 358,
          // height: 201,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 0.50,
                color: Colors.black.withOpacity(0.10000000149011612),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 358,
                            height: 40,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 3.75,
                                  top: 6.25,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            "https://reclaim-react-native-sdk.s3.ap-south-1.amazonaws.com/Logomark.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  left: 130,
                                  top: 13,
                                  child: SizedBox(
                                    height: 16,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 322,
                                          child: Text(
                                            'Powered by Reclaim Protocol',
                                            style: TextStyle(
                                              color: Colors.black45,
                                              fontSize: 13,
                                              fontFamily: 'Manrope',
                                              fontWeight: FontWeight.w500,
                                              height: 1.23,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        height: 1.20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 322,
                            child: Text(
                              widget.subTitle,
                              style: TextStyle(
                                color: Colors.black
                                    .withOpacity(0.6000000238418579),
                                fontSize: 13,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                height: 1.23,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _claimState.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Material(
                          color: const Color(0xFF322EED),
                          child: InkWell(
                            onTap: () {
                              _openWebView(
                                  context,
                                  widget.requestedProofs[0].loginUrl,
                                  widget.requestedProofs,
                                  widget.onSuccess,
                                  widget.onFail);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                widget.cta,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontFamily: 'Manrope',
                                                  fontWeight: FontWeight.w700,
                                                  height: 1.33,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ))
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 322,
                              child: Text(
                                _claimState,
                                style: TextStyle(
                                  color: Colors.black
                                      .withOpacity(0.6000000238418579),
                                  fontSize: 13,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w500,
                                  height: 1.23,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class SwiggyWebViewScreen extends StatelessWidget {
  BuildContext context;
  Uri url;
  List<SwiggyRequestedProof> requestedProofs;
  final Function(String webViewData) onModification;
  final Function(dynamic parseData) onParseResult;
  final Function(String cookieStrData) onCookieStrData;
  Function(Map<String, dynamic> proofs) onSuccess;
  Function(Exception e) onFail;
  // Create WebViewController
  var controller = WebViewController();
  final cookieManager = WebviewCookieManager();
  late String cookieStr;
  late dynamic parseResult;
  late Timer timer;
  bool oneTimeRun = false;
  bool watchDog = false;
  SwiggyWebViewScreen(
      {Key? key,
      required this.context,
      required this.url,
      required this.requestedProofs,
      required this.onModification,
      required this.onParseResult,
      required this.onCookieStrData,
      required this.onSuccess,
      required this.onFail})
      : super(key: key) {
    // Configure WebViewController
    cookieManager.clearCookies();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageFinished: (String url) async {
            if (!oneTimeRun) {
              timer =
                  Timer.periodic(const Duration(seconds: 2), (Timer t) async {
                if (watchDog) {
                  return;
                }
                final gotCookies =
                    await cookieManager.getCookies(requestedProofs[0].loginUrl);
                List<String> foundCookies = [];
                bool found = requestedProofs[0].loginCookies.every((cookie) {
                  if (gotCookies.indexWhere((item) => item.name == cookie) !=
                      -1) {
                    foundCookies.add(cookie);
                    return true;
                  }
                  return false;
                });
                if (found) {
                  watchDog = true;
                  timer.cancel();
                  cookieStr =
                      gotCookies.map((c) => '${c.name}=${c.value}').join('; ');
                  onCookieStrData(cookieStr);
                  final response = await http.get(
                    Uri.parse(requestedProofs[0].url),
                    headers: {
                      'Cookie': cookieStr,
                    },
                  );
                  if (response.statusCode == 200) {
                    parseResult = response.body;
                    onParseResult(parseResult);
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    onFail(Exception('Failed to load JSON data from url'));
                    throw Exception('Failed to load JSON data from url');
                  }
                }
              });
              oneTimeRun = false;
            }
          },
        ),
      )
      ..loadRequest(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WebViewWidget(controller: controller),
    );
  }
}
