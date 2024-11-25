import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xstream/model/update_checker_model.dart'; // For getting app version info

class UpdateChecker {
  final Dio _dio = Dio();

  final String owner = 'SanuSanal';
  final String repo = 'xstream';

  Future<UpdateCheckerData?> getLatestReleaseVersion() async {
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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> checkForUpdate(BuildContext context) async {
    final versionDetails = await getLatestReleaseVersion();
    if (versionDetails == null) return;

    var latestVersion = versionDetails.version;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    // if (_hasNewerVersion(currentVersion, latestVersion) && context.mounted) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Available'),
            content: Text(
                'A new version ($latestVersion) is available. Would you like to update?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Later'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Update'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Replace the URL with the download link of your app
                  // _launchURL('https://github.com/$owner/$repo/releases/latest',
                  //     context);

                  _downloadAndInstallApk(
                      context, versionDetails.v8aDownloadUrl);
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _launchURL(String repoUrl, BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    Uri url = Uri.parse(repoUrl);
    if (await canLaunchUrl(url)) {
      launchUrl(url);
    } else {
      Clipboard.setData(ClipboardData(text: repoUrl));
      scaffoldMessenger.showSnackBar(
        const SnackBar(
            content: Text('Url copied to clipboard. Open in a browser.')),
      );
    }
  }

  Future<void> _downloadAndInstallApk(
      BuildContext context, String apkUrl) async {
    final progressNotifier = ValueNotifier<double>(0.0);
    bool isDialogVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (context, progress, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      value: progress > 0 ? progress : null,
                      strokeWidth: 6.0,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    ).then((_) {
      isDialogVisible = false;
    });

    try {
      final directory = await getTemporaryDirectory();
      final apkPath = '${directory.path}/update.apk';

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Downloading update...")),
        );
      }

      await _dio.download(
        apkUrl,
        apkPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            progressNotifier.value = progress;

            if (progress >= 1.0 && isDialogVisible) {
              // Navigator.of(context).pop(); // Close the dialog
              isDialogVisible = false;
            }
          }
        },
      );

      File apkFile = File(apkPath);

      if (apkFile.existsSync()) {
        if (context.mounted) {
          if (isDialogVisible) {
            Navigator.of(context).pop(); // Close dialog on error
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Download complete! Installing update...")),
          );
        }

        await OpenFilex.open(apkPath);

        File(apkPath).deleteSync();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("APK file not found!")),
          );
        }
        throw Exception("APK file not found!");
      }
    } catch (e) {
      if (context.mounted) {
        _launchURL('https://github.com/$owner/$repo/releases/latest', context);
      }
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
