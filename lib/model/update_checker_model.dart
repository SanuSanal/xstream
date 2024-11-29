class UpdateCheckerData {
  final String version;
  final String v8aDownloadUrl;
  final String v7aDownloadUrl;
  final String x86DownloadUrl;

  UpdateCheckerData({
    required this.version,
    required this.v8aDownloadUrl,
    required this.v7aDownloadUrl,
    required this.x86DownloadUrl,
  });

  static UpdateCheckerData empty() {
    return UpdateCheckerData(
        version: "",
        v8aDownloadUrl: "",
        v7aDownloadUrl: "",
        x86DownloadUrl: "");
  }
}
