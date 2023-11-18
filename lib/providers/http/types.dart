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
