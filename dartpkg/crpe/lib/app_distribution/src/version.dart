final startVersion = RegExp(r'^' // Start at beginning.
    r'(\d+)\.(\d+)\.(\d+)' // Version Number.
    r'(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?' // Build Number.
    r'(\-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?'); // Hash.

final completeVersion = RegExp('${startVersion.pattern}\$');

class Version {
  static Version from({
    required String version,
    String? buildNumber,
  }) {
    return Version.parse("${version}-${buildNumber ?? "0"}");
  }

  static Version? parseAndGetLatest(List<String> tags) {
    final versions = tags
        .map((e) {
          try {
            return Version.parse(e);
          } catch (e) {
            return null;
          }
        })
        .whereType<Version>()
        .toList()
      ..sort((a, b) => -a.compareTo(b));

    return versions.firstOrNull;
  }

  factory Version.parse(String v) {
    if (v.startsWith("v")) {
      v = v.substring(1);
    }

    final match = completeVersion.firstMatch(v);
    if (match == null) {
      throw FormatException('Could not parse "$v".');
    }

    try {
      var major = int.parse(match[1]!);
      var minor = int.parse(match[2]!);
      var patch = int.parse(match[3]!);
      var buildNumber = match[5]!;
      // var build = match[8];

      return Version(
        major: major,
        minor: minor,
        patch: patch,
        buildNumber: buildNumber,
      );
    } on FormatException {
      throw FormatException('Could not parse "$v".');
    }
  }

  int major;
  int minor;
  int patch;
  String buildNumber;

  Version({
    required this.major,
    required this.minor,
    required this.patch,
    required this.buildNumber,
  });

  @override
  String toString() {
    return "v${major}.${minor}.${patch}-${buildNumber}";
  }

  int compareTo(Version other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);

    return buildNumber.compareTo(other.buildNumber);
  }

  bool operator >(Version other) => compareTo(other) > 0;

  bool operator <(Version other) => compareTo(other) < 0;

  bool operator <=(Version other) => compareTo(other) <= 0;

  bool operator >=(Version other) => compareTo(other) >= 0;
}
