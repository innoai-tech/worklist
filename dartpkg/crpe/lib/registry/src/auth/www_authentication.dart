import 'dart:convert';
import 'dart:io';

import 'package:roundtripper/roundtripper.dart';

import 'repository_scope.dart';
import 'token.dart';

abstract class Author {
  String get username;

  Request patch(Request request);
}

class BasicAuth implements Author {
  final String username;
  final String password;

  const BasicAuth({
    required this.username,
    required this.password,
  });

  @override
  Request patch(Request request) {
    return request.copyWith(headers: {
      ...?request.headers,
      "authorization":
          "Basic ${base64Encode(utf8.encode("${username}:${password}"))}"
    });
  }
}

class WwwAuthentication implements RoundTripBuilder {
  Author Function() getAuthor;

  WwwAuthentication(this.getAuthor);

  final Map<String, Token> _tokens = {};

  Token? validTokenFor(String username, String scope) {
    return _tokens["${username}/${scope}"]?.let((t) => t.valid ? t : null);
  }

  @override
  RoundTrip build(RoundTrip next) {
    return (request) async {
      final scope = RepositoryScope.fromUri(
        request.method,
        request.uri,
      );

      final tok = validTokenFor(getAuthor().username, scope.toString());

      if (tok != null) {
        return next(
          request.copyWith(
            headers: tok.applyAuthHeader(request.headers ?? {}),
          ),
        );
      }

      try {
        return await next(request);
      } on ResponseException catch (err) {
        if (err.statusCode != HttpStatus.unauthorized) {
          rethrow;
        }

        var token = await exchangeTokenIfNeed(
          next,
          err.response?.headers["www-authenticate"]?.first ?? "",
        );

        if (token != null) {
          return retryWithToken(next, token, request);
        }

        return err.response!;
      }
    };
  }

  retryWithToken(RoundTrip next, Token token, Request request) {
    return next(
      request.copyWith(
        headers: token.applyAuthHeader(request.headers ?? {}),
      ),
    );
  }

  Future<Token?> exchangeTokenIfNeed(
    RoundTrip roundTrip,
    String wwwAuthHeader,
  ) async {
    final author = getAuthor();
    final authn = WwwAuthenticate.parse(wwwAuthHeader);

    var resp = await roundTrip(
      author.patch(Request.uri(
        authn.realm,
        method: "GET",
        queryParameters: {
          ...?authn.service?.let((v) => {"service": v}),
          ...?authn.scope?.let((v) => {"scope": v}),
        },
      )),
    );

    final token = Token.fromJson({
      ...(await resp.json()),
      "type": authn.type,
    });

    authn.forEachScope((scope) {
      _tokens["${author.username}/${scope}"] = token;
    });

    return token;
  }
}

extension _ObjectExt<T> on T {
  R let<R>(R Function(T that) op) => op(this);
}

class WwwAuthenticate {
  final String type;
  final String realm;
  final String? service;
  final String? scope;

  const WwwAuthenticate({
    required this.type,
    required this.realm,
    this.service,
    this.scope,
  });

  factory WwwAuthenticate.parse(String value) {
    final v = HeaderValue.parse(value, parameterSeparator: ",");

    return WwwAuthenticate(
      type: v.value,
      realm: v.parameters["realm"]!,
      service: v.parameters["service"],
      scope: v.parameters["scope"],
    );
  }

  void forEachScope(void Function(String scope) action) {
    if (scope != null) {
      final parts = scope!.split(":");
      final prefix = parts.sublist(0, parts.length - 1);
      final last = parts.last;

      last.split(",").forEach((s) {
        action([
          ...prefix,
          s,
        ].join(":"));
      });
    }
  }
}

class ErrInvalidWwwAuthenticate implements Exception {
  final String value;

  const ErrInvalidWwwAuthenticate({
    required this.value,
  });
}
