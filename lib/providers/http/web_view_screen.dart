import 'package:flutter/material.dart';
import 'package:reclaim_flutter/providers/http/types.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

// ignore: must_be_immutable
class WebViewScreen extends StatelessWidget {
  final BuildContext context;
  final Uri url;
  final List<RequestedProof> requestedProofs;
  final Function(String webViewData, String cookieStr, dynamic parseResult)
      onModification;
  final Function(String status) onStatusChange;
  final Function(Map<String, dynamic> proofs) onSuccess;
  final Function(Exception e) onFail;

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
  }) : super(key: key) {
    // Configure WebViewController
    cookieManager.clearCookies();
    controller.reload();
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
        'Claim',
        onMessageReceived: (JavaScriptMessage message) async {
          onModification(
              'Please wait, Initiating Claim Creation', cookieStr, parseResult);
          Navigator.pop(context);
        },
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            //  print("Loading ${progress}%");
          },
          onPageFinished: (String url) async {
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