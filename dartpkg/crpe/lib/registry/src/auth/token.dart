class Token {
  final String type;
  final String accessToken;
  final int expiresIn;
  final DateTime? issuedAt;

  const Token({
    required this.type,
    required this.accessToken,
    required this.expiresIn,
    this.issuedAt,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    final maybeIssuedAt = () {
      if (json["issuedAt"] != null) {
        return DateTime.parse(json["issuedAt"]);
      }
    };

    return Token(
      type: json["type"] as String,
      accessToken: (json["token"] ?? json["accessToken"]) as String,
      expiresIn: json["expires_in"] as int,
      issuedAt: maybeIssuedAt(),
    );
  }

  bool get valid {
    return accessToken != "" && !_tokenExpires;
  }

  bool get _tokenExpires => DateTime.now().isAfter(
        (issuedAt ?? DateTime.now()).add(Duration(seconds: expiresIn - 30)),
      );

  Map<String, dynamic> applyAuthHeader(Map<String, dynamic> headers) {
    return {...headers, "authorization": "$type $accessToken"};
  }
}
