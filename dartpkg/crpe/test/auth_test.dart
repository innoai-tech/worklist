import 'package:crpe/registry/auth.dart';
import 'package:test/test.dart';

void main() {
  group("WwwAuthentication", () {
    test("parseWwwAuthHeader", () {
      final ret = WwwAuthenticate.parse(
        'Bearer realm="https://x.io/service/token",service="harbor-registry",scope="repository:worklist/example:pull,push"',
      );

      expect(ret.type, equals("Bearer"));
      expect(ret.realm, equals("https://x.io/service/token"));
      expect(ret.service, equals("harbor-registry"));
      expect(ret.scope, equals("repository:worklist/example:pull,push"));
    });
  });
}
