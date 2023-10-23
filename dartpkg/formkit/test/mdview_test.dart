import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/mdview/src/blob_uri.dart';

void main() {
  group("Uri", () {
    test("parse", () {
      final b =
          "blob:image/png+gzip;sha256,554a3790cd3a450e00c49d090b213bab969e2202e9ad052f63eab326c30d9655";

      final bu = BlobURI.parse(b);

      expect(bu.toString(), equals(b));
    });
  });
}
