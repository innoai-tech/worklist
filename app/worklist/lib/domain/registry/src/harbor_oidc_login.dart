import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide Cookie;
import 'package:roundtripper/roundtripper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import './registry.dart';

class HarborOidcAutoLogin implements RoundTripBuilder {
  BuildContext context;
  Function(Registry registry) onLogon;

  HarborOidcAutoLogin({
    required this.context,
    required this.onLogon,
  });

  @override
  RoundTrip build(RoundTrip next) {
    return (request) async {
      try {
        return await next(request);
      } on ResponseException catch (err) {
        if (err.statusCode != HttpStatus.unauthorized) {
          rethrow;
        }

        final uri = err.response!.request.uri;
        final registry$ = PublishSubject<Registry>();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => _HarborOidcLogin(
              url: uri,
              onLogon: (registry) {
                onLogon(registry);
                registry$.add(registry);
              },
            ),
          ),
        );

        await registry$.first;

        return retryWithToken(next, request);
      }
    };
  }

  retryWithToken(RoundTrip next, Request request) {
    return next(request);
  }
}

class _HarborOidcLogin extends SetupWidget<_HarborOidcLogin> {
  final Uri url;
  final Function(Registry registry) onLogon;

  const _HarborOidcLogin({
    required this.url,
    required this.onLogon,
    super.key,
  });

  @override
  setup(sc) {
    return () {
      final loginURI = sc.widget.url.copyWith(
        path: "/c/oidc/login",
        queryParameters: {
          "redirect_url": "/api/v2.0/users/current",
        },
      );

      final userInfoURI =
          sc.widget.url.copyWith(path: "/api/v2.0/users/current");

      return Scaffold(
        appBar: AppBar(),
        body: InAppWebView(
          key: Key(loginURI.toString()),
          initialUrlRequest: URLRequest(
            url: WebUri.uri(loginURI),
          ),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url!;
            if (uri.toString().startsWith("lark:")) {
              launchUrl(uri);
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (c, req) async {
            if (req == null) {
              return;
            }
            if (req.host == userInfoURI.host && req.path == userInfoURI.path) {
              final data = jsonDecode(
                await c.evaluateJavascript(
                  source: "window.document.body.textContent",
                ),
              );

              onLogon(Registry.fromURI(sc.widget.url).copyWith(
                username: data["username"]! as String,
                password: data["oidc_user_meta"]["secret"] as String,
              ));

              Navigator.pop(sc.context);

              return;
            }
          },
        ),
      );
    };
  }
}

extension _UriExt on Uri {
  copyWith({
    String? scheme,
    String? host,
    int? port,
    String? path,
    Map<String, dynamic>? queryParameters,
    String? userInfo,
    String? fragment,
  }) {
    return Uri(
      scheme: scheme ?? this.scheme,
      host: host ?? this.host,
      port: port ?? this.port,
      path: path ?? this.path,
      queryParameters: queryParameters ?? this.queryParameters,
      userInfo: userInfo ?? this.userInfo,
      fragment: fragment ?? this.fragment,
    );
  }
}
