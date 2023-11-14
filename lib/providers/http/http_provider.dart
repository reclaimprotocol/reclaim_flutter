import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:web3dart/crypto.dart';
import 'dart:math';
import 'package:web3dart/web3dart.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable
class WebViewScreen extends StatelessWidget {
  final BuildContext context;
  final Uri url;
  final List<RequestedProof> requestedProofs;
  final Function(String webViewData) onModification;
  final Function(String status) onStatusChange;
  final Function(Map<String, dynamic> proofs) onSuccess;
  final Function(Exception e) onFail;
  final bool showShell;
  final BoxDecoration? shellStyles;

  static void _defaultOnStatusChange(String input) {}

  var controller = WebViewController();
  final cookieManager = WebviewCookieManager();
  late String cookieStr;
  late dynamic parseResult;

  WebViewScreen({
    Key? key,
    required this.context,
    required this.url,
    required this.requestedProofs,
    required this.onModification,
    required this.onSuccess,
    required this.onFail,
    this.onStatusChange = _defaultOnStatusChange,
    this.showShell = true,
    this.shellStyles,
  }) : super(key: key) {
    // Configure WebViewController
    cookieManager.clearCookies();
    controller
      ..addJavaScriptChannel(
        'Login',
        onMessageReceived: (JavaScriptMessage message) {
          parseResult = parseHtml(message.message,
              requestedProofs[0].responseSelections[0].responseMatch);
          controller.runJavaScript('''Claim.postMessage("Init")''');
        },
      )
      ..addJavaScriptChannel(
        'Check',
        onMessageReceived: (JavaScriptMessage message) {
          var response = jsonDecode(message.message);
          if (response["type"] == "createClaimStep") {
            if (response["step"]["name"] == "creating") {
              Fluttertoast.showToast(
                  msg: "Creating Claim",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 2,
                  textColor: Colors.white,
                  fontSize: 16.0,
                  backgroundColor: const Color.fromARGB(255, 86, 86, 86));
              onModification('Creating Claim');
            }
            if (response["step"]["name"] == "witness-done") {
              Fluttertoast.showToast(
                  msg: "Claim Created Successfully",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 2,
                  textColor: Colors.white,
                  fontSize: 16.0,
                  backgroundColor: const Color.fromARGB(255, 86, 86, 86));
              onModification('Claim Created Successfully');
            }
          }
          if (response["type"] == "createClaimDone") {
            Navigator.pop(context);
            onSuccess(response["response"]);
          }

          if (response["type"] == "error") {
            onModification('Claim Creation Failed');
            Navigator.pop(context);
            onFail(Exception("${response["data"]["message"]}"));
          }
        },
      )
      ..addJavaScriptChannel(
        'Claim',
        onMessageReceived: (JavaScriptMessage message) async {
          controller
              .loadRequest(Uri.parse("https://sdk-rpc.reclaimprotocol.org/"));
          Fluttertoast.showToast(
              msg: "Initiating Claim Creation",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              textColor: Colors.white,
              fontSize: 16.0,
              backgroundColor: const Color.fromARGB(255, 86, 86, 86));
          onModification('Please wait, Initiating Claim Creation');
        },
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            //  print("Loading ${progress}%");
          },
          onPageFinished: (String url) async {
            if (url == "https://sdk-rpc.reclaimprotocol.org/") {
              var random = Random.secure();
              EthPrivateKey priKey = EthPrivateKey.createRandom(random);
              String privateKey =
                  bytesToHex(priKey.privateKey, include0x: true);
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
                    "url": requestedProofs[0].url,
                    "method": "GET",
                    "responseSelections": [
                      {
                        "responseMatch": parseResult["result"],
                      }
                    ]
                  },
                  "secretParams": {
                    "cookieStr": cookieStr,
                  },
                  "ownerPrivateKey": privateKey,
                }
              };

              controller.runJavaScript('''postMessage(${jsonEncode(req)})''');
              return;
            }
            final gotCookies =
                await cookieManager.getCookies(requestedProofs[0].loginUrl);
            List<String> foundCookies = [];
            bool found = requestedProofs[0].loginCookies.every((cookie) {
              if (gotCookies.indexWhere((item) => item.name == cookie) != -1) {
                foundCookies.add(cookie);
                return true;
              }
              return false;
            });

            if (found) {
              cookieStr =
                  gotCookies.map((c) => '${c.name}=${c.value}').join('; ');
              if (requestedProofs[0].url.replaceAll(RegExp(r'/$'), '') ==
                  url.replaceAll(RegExp(r'/$'), '')) {
                controller.runJavaScript(
                    '''Login.postMessage(document.documentElement.outerHTML)''');
              } else {
                controller.loadRequest(Uri.parse(requestedProofs[0].url));
              }
            }
          },
        ),
      )
      ..loadRequest(url);
  }

  Map<String, dynamic> parseHtml(String html, String regexString) {
    // replace {{VARIABLE}} with (.*?), and save the variable names
    List<String> variableNames = [];
    String realRegexString = regexString.replaceAllMapped(
      RegExp(r'{{(.*?)}}'),
      (match) {
        variableNames.add(match.group(1)!);
        return '(.*?)';
      },
    );

    // create a RegExp object
    RegExp regex = RegExp(realRegexString, multiLine: true, dotAll: true);

    // run the regex on the html
    Match? match = regex.firstMatch(html);

    if (match == null) {
      Navigator.pop(context);
      onFail(Exception("Regex does not match"));
      throw 'Regex does not match';
    }

    // replace the variable placeholders in the original regex string with their values
    String result = regexString;
    Map<String, dynamic> params = {};
    for (int i = 0; i < variableNames.length; i++) {
      result =
          result.replaceAll('{{${variableNames[i]}}}', match.group(i + 1)!);
      params[variableNames[i]] = match.group(i + 1)!;
    }

    return {'result': result, 'params': params};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WebViewWidget(controller: controller),
    );
  }
}

class RequestedProof {
  final String url;
  final String loginUrl;
  final List<String> loginCookies;
  final List<ResponseSelection> responseSelections;

  RequestedProof(
      {required this.url,
      required this.loginUrl,
      required this.loginCookies,
      required this.responseSelections});
}

class ResponseSelection {
  final String responseMatch;

  ResponseSelection({required this.responseMatch});
}

// ignore: must_be_immutable
class ReclaimHttps extends StatefulWidget {
  final List<RequestedProof> requestedProofs;
  final String title;
  final String subTitle;
  String cta;
  final Function(String status) onStatusChange;
  final Function(Map<String, dynamic> proofs) onSuccess;
  final Function(Exception e) onFail;
  final bool showShell;
  BoxDecoration? shellStyles;

  static void _defaultOnStatusChange(String input) {}

  ReclaimHttps({
    Key? key,
    required this.requestedProofs,
    required this.title,
    required this.subTitle,
    required this.cta,
    required this.onSuccess,
    required this.onFail,
    this.onStatusChange = _defaultOnStatusChange,
    this.showShell = true,
    this.shellStyles,
  }) : super(key: key);

  @override
  ReclaimHttpsState createState() => ReclaimHttpsState();
}

class ReclaimHttpsState extends State<ReclaimHttps> {
  String _claimState = "";

  String get claimState => _claimState;

  void triggerOpenWebView() {
    _openWebView(
        context,
        widget.requestedProofs[0].loginUrl,
        widget.requestedProofs,
        widget.onStatusChange,
        widget.onSuccess,
        widget.onFail);
  }

  void _openWebView(
      BuildContext context,
      String url,
      List<RequestedProof> requestedProofs,
      Function(String status) onStatusChange,
      Function(Map<String, dynamic> proofs) onSuccess,
      Function(Exception e) onFail) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebViewScreen(
            context: context,
            url: Uri.parse(url),
            requestedProofs: requestedProofs,
            onModification: (webViewData) {
              setState(() {
                _claimState = webViewData;
                onStatusChange(webViewData);
              });
            },
            onSuccess: onSuccess,
            onFail: onFail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final containerStyles = widget.shellStyles ?? const BoxDecoration();

    return Column(
      children: [
        Container(
            width:
                widget.showShell ? MediaQuery.of(context).size.width * 0.9 : 0,
            padding:
                widget.showShell ? const EdgeInsets.all(16) : EdgeInsets.zero,
            clipBehavior: Clip.none,
            decoration: containerStyles,
            child: widget.showShell ? buildHeader(context) : const SizedBox()),
      ],
    );
  }

  Widget buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: buildLogoAndTitle(context),
          ),
        ],
      ),
    );
  }

  Widget buildLogoAndTitle(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLogo(),
        const SizedBox(height: 8),
        buildTitle(),
        buildSubtitle(),
        const SizedBox(height: 16),
        _claimState.isEmpty ? buildClaimButton() : buildClaimState(),
      ],
    );
  }

  Widget buildLogo() {
    return SizedBox(
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget buildTitle() {
    return Text(
      widget.title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
        height: 1.20,
      ),
    );
  }

  Widget buildSubtitle() {
    return SizedBox(
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
                color: Colors.black.withOpacity(0.6),
                fontSize: 13,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                height: 1.23,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildClaimButton() {
    return Container(
      width: double.infinity,
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
                widget.onStatusChange,
                widget.onSuccess,
                widget.onFail,
              );
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
      ),
    );
  }

  Widget buildClaimState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  color: Colors.black.withOpacity(0.6),
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
    );
  }
}
