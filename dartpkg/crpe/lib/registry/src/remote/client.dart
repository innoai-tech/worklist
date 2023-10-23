import 'package:roundtripper/roundtripbuilders.dart';
import 'package:roundtripper/roundtripper.dart';
import 'package:storage/errcode/errcode.dart';

// https://github.com/opencontainers/distribution-spec/blob/main/spec.md#endpoints
class ClientProvider {
  final String endpoint;
  final List<RoundTripBuilder>? roundTripBuilders;

  ClientProvider({
    required this.endpoint,
    this.roundTripBuilders,
  });

  factory ClientProvider.fromUri(String endpoint) {
    var u = Uri.parse(endpoint);

    return ClientProvider(
      endpoint: u.replace(userInfo: "").toString(),
    );
  }

  Client? _client;

  Client get client {
    return _client ??= Client(
      roundTripBuilders: [
        _PatchEndpoint(Uri.parse(endpoint)),
        ...?roundTripBuilders,
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
