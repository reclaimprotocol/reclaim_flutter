import 'package:flutter/material.dart';
import 'package:reclaim_flutter/providers/http/hidden_web_view.dart';
import 'package:reclaim_flutter/providers/http/web_view_screen.dart';
import 'package:reclaim_flutter/providers/http/types.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  String cookieStr = "";
  dynamic parseResult;
  bool extracted = false;

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
            url: Uri.parse(widget.requestedProofs[0].url),
            requestedProofs: requestedProofs,
            onModification: (webViewData, cookieStr, parseResult) {
              setState(() {
                _claimState = webViewData;
                this.cookieStr = cookieStr;
                this.parseResult = parseResult;
                extracted = true;
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
            child: widget.showShell
                ? buildHeader(context)
                : extracted
                    ? buildwebView(context)
                    : const SizedBox()),
      ],
    );
  }

  Widget buildwebView(BuildContext context) {
    return SizedBox(
        width: 0,
        height: 0,
        child: HiddenWebViewScreen(
            context: context,
            requestedProofs: widget.requestedProofs,
            onModification: (webViewData) {
              setState(() {
                _claimState = webViewData;
                widget.onStatusChange(webViewData);
                if (webViewData == 'Claim Created Successfully' ||
                    webViewData == 'Claim Creation Failed') {
                  extracted = false;
                }
              });
            },
            onSuccess: widget.onSuccess,
            onFail: widget.onFail,
            parseResult: parseResult,
            cookieStr: cookieStr));
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
        extracted ? buildwebView(context) : const SizedBox(),
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
                                  color: Color.fromARGB(255, 0, 0, 0),
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
    bool shouldShowSpinner =
        _claimState == 'Please wait, Initiating Claim Creation' ||
            _claimState == 'Creating Claim';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shouldShowSpinner)
            const SpinKitFadingCircle(
              color: Color.fromARGB(255, 0, 0, 0),
              size: 15,
            ),
          if (shouldShowSpinner)
            const SizedBox(
              width: 8,
            ),
          Flexible(
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
    );
  }
}
