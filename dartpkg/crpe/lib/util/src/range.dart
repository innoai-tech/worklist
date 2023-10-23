import 'dart:io';

import 'package:storage/storage.dart';

class Range {
  String unit;
  int start;
  int? end;

  Range(
    this.unit, {
    required this.start,
    this.end,
  });

  factory Range.parse(String range) {
    String unit = "";
    int start = 0;
    int? end;

    var parts = range.toLowerCase().split("=");

    unit = parts[0];

    if (unit.length != 2) {
      throw ErrRangeInvalid(range: range);
    }

    var startAndEnd = parts[1].split("-");

    try {
      start = int.parse(startAndEnd[0]);
      if (startAndEnd[1] != "") {
        end = int.parse(startAndEnd[1]);
      }
    } catch (_) {
      throw ErrRangeInvalid(range: range);
    }

    return Range(unit, start: start, end: end);
  }

  @override
  String toString() {
    return "$unit=$start-${end ?? ""}";
  }
}

class ErrRangeInvalid implements StatusError {
  final String range;

  const ErrRangeInvalid({
    required this.range,
  });

  @override
  String get code => "RANGE_INVALID";

  @override
  int get status => HttpStatus.badRequest;

  @override
  String toString() => "invalid range ${this.range}";

  @override
  Map<String, dynamic>? toJson() {
    return {"range": this.range};
  }
}
