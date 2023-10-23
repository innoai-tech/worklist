abstract class ArtifactType {
  static const Schema = "application/vnd.worklist.schema+type";
  static const FormData = "application/vnd.worklist.formdata+type";
}

abstract class ManifestType {
  static const Schema = "application/vnd.worklist.config.v1+json";
  static const FormData = "application/vnd.worklist.formdata+json";
}
