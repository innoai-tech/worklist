import 'package:crpe/registry/auth.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:roundtripper/roundtripbuilders.dart';
import 'package:roundtripper/roundtripper.dart';
import 'package:storage/errcode/errcode.dart';

part "__generated__/client.g.dart";

// https://github.com/opencontainers/distribution-spec/blob/main/spec.md#endpoints

@JsonSerializable()
class ClientProvider {
  final String endpoint;
  final String? username;
  final String? password;

  ClientProvider({
    required this.endpoint,
    this.username,
    this.password,
  });

  factory ClientProvider.fromUri(String endpoint) {
    var u = Uri.parse(endpoint);

    var parts = u.userInfo.split(":");

    return ClientProvider(
      endpoint: u.replace(userInfo: "").toString(),
      username: parts.firstOrNull,
      password: parts.length == 2 ? parts.lastOrNull : null,
    );
  }

  String text() {
    return Uri.parse(endpoint).replace(userInfo: username ?? "").toString();
  }

  factory ClientProvider.fromJson(Map<String, dynamic> json) =>
      _$ClientProviderFromJson(json);

  Map<String, dynamic> toJson() {
    return _$ClientProviderToJson(this);
  }

  Client? _client;

  Client get client {
    return _client ??= Client(
      roundTripBuilders: [
        _PatchEndpoint(Uri.parse(endpoint)),
        WwwAuthentication(
          username: username,
          password: password,
        ),
        _ThrowResponseError(),
        RequestLog(),
      ],
    );
  }
}

class _PatchEndpoint implements RoundTripBuilder {
  Uri endpoint;

  _PatchEndpoint(this.endpoint);

  @override
  RoundTrip build(RoundTrip next) {
    return (request) async {
      return next(
        request.copyWith(
          uri: Uri(
            scheme: endpoint.scheme,
            host: endpoint.host,
            port: endpoint.port,
            //
            path: request.uri.path,
            queryParameters: request.uri.queryParameters,
            fragment: request.uri.fragment,
          ),
        ),
      );
    };
  }
}

class _ThrowResponseError implements RoundTripBuilder {
  @override
  RoundTrip build(RoundTrip next) {
    return (request) async {
      var resp = await next(request);
      if (resp.statusCode >= HttpStatus.badRequest) {
        var bytes = await resp.blob();

        if (bytes.isNotEmpty &&
            (resp.headers["content-type"]?.contains("json") ?? false)) {
          resp.body = StatusErrors.fromJson(await resp.json());

          throw ResponseException(
            resp.statusCode,
            response: resp,
          );
        } else {
          resp.body = await resp.text();

          throw ResponseException(
            resp.statusCode,
            response: resp,
          );
        }
      }
      return resp;
    };
  }
}
