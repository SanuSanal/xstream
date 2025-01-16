import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xstream/model/update_checker_model.dart';

class AppUpdateWidget extends StatefulWidget {
  final VoidCallback onUpdateComplete;

  const AppUpdateWidget({super.key, required this.onUpdateComplete});

  @override
  AppUpdateWidgetState createState() => AppUpdateWidgetState();
}

class AppUpdateWidgetState extends State<AppUpdateWidget> {
  final String owner = 'SanuSanal';
  final String repo = 'xstream';
  final Dio _dio = Dio();

  bool _isDownloading = false;
  double _progress = 0.0;
  String _downloadUrl = "";
  String _latestVersion = "";

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    UpdateCheckerData versionData = await _getLatestReleaseVersion();

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final abis = androidInfo.supportedAbis;

    if (abis.isNotEmpty) {
      var abi = abis.first;
      if ("arm64-v8a" == abi) {
        _downloadUrl = versionData.v8aDownloadUrl;
      } else if ("armeabi-v7a" == abi) {
        _downloadUrl = versionData.v7aDownloadUrl;
      } else {
        _downloadUrl = versionData.x86DownloadUrl;
      }
    }

    if (_hasNewerVersion(currentVersion, versionData.version) &&
        _downloadUrl.isNotEmpty) {
      _latestVersion = versionData.version;
      _showConfirmationDialog();
    }
  }

  Future<void> _startDownload() async {
    try {
      final directory = await getTemporaryDirectory();
      final apkPath = '${directory.path}/update.apk';

      await _dio.download(
        _downloadUrl,
        apkPath,
        onReceiveProgress: (received, total) {
          setState(() {
            if (total != -1) {
              _progress = received / total;

              if (_progress >= 1.0) {
                _isDownloading = false;
              }
            }
          });
        },
      );

      File apkFile = File(apkPath);
      if (apkFile.existsSync()) {
        await OpenFilex.open(apkPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ready to install. Click update!')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isDownloading = true;
      });
    }

    widget.onUpdateComplete();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Update'),
        content: Text(
            'A new version $_latestVersion is available. Would you like to update?'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onUpdateComplete();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startDownload();
              setState(() {
                _isDownloading = true;
              });
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isDownloading
          ? Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const SizedBox.expand(),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _progress > 0 ? _progress : null,
                      strokeWidth: 6.0,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "${(_progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Future<UpdateCheckerData> _getLatestReleaseVersion() async {
    final url = 'https://api.github.com/repos/$owner/$repo/releases/latest';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var latestVersion = data['tag_name'];
        var v8aDownloadUrl = '';
        var v7aDownloadUrl = '';
        var x86DownloadUrl = '';
        for (var asset in data['assets']) {
          if ((asset['name'] as String).contains('v8a')) {
            v8aDownloadUrl = asset['browser_download_url'];
          } else if ((asset['name'] as String).contains('v7a')) {
            v7aDownloadUrl = asset['browser_download_url'];
          } else if ((asset['name'] as String).contains('x86_64')) {
            x86DownloadUrl = asset['browser_download_url'];
          }
        }

        return UpdateCheckerData(
            version: latestVersion,
            v8aDownloadUrl: v8aDownloadUrl,
            v7aDownloadUrl: v7aDownloadUrl,
            x86DownloadUrl: x86DownloadUrl);
      } else {
        return UpdateCheckerData.empty();
      }
    } catch (e) {
      return UpdateCheckerData.empty();
    }
  }

  bool _hasNewerVersion(String currentVersion, String latestVersion) {
    List<int> cvParts = currentVersion.split('.').map(int.parse).toList();
    List<int> lvParts = latestVersion.split('.').map(int.parse).toList();

    int maxLength =
        [cvParts.length, lvParts.length].reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < maxLength; i++) {
      int cvPart = i < cvParts.length ? cvParts[i] : 0;
      int lvPart = i < lvParts.length ? lvParts[i] : 0;

      if (cvPart < lvPart) {
        return true;
      }
    }
    return false;
  }
}
