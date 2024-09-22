import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart'; // For getting app version info

class UpdateChecker {
  final String owner = 'SanuSanal';
  final String repo = 'Football-Live';

  Future<String?> getLatestReleaseVersion() async {
    final url = 'https://api.github.com/repos/$owner/$repo/releases/latest';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['tag_name'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> checkForUpdate(BuildContext context) async {
    final latestVersion = await getLatestReleaseVersion();
    if (latestVersion == null) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    if (_hasNewerVersion(currentVersion, latestVersion) && context.mounted) {
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
                  _launchURL('https://github.com/$owner/$repo/releases/latest',
                      context);
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
