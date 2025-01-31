import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xstream/screens/about_page.dart';
import 'package:xstream/screens/donate_page.dart';
import 'package:xstream/screens/home_page_not_found_page.dart';
import 'package:xstream/screens/match_schedule_page.dart';
import 'package:xstream/screens/navigation_controls.dart';
import 'package:xstream/screens/settings_page.dart';
import 'package:xstream/service/database_service.dart';
import 'package:xstream/util/app_update_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  String _version = '';
  String _homepage = "";
  bool _isWebviewloaded = false;
  bool _isLoading = false;
  bool _switchModeOnFullscreen = true;
  bool _initiateUpdateCheck = false;
  List<String> whiteListedDomains = [];

  final dbService = DatabaseService();
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _refreshConfigandDomains();
    _initializeWebView();

    _checkForUpdates();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkForUpdates() async {
    String? checkUpdates = await dbService.getConfigurationValue('auto_update');

    if (checkUpdates != null && int.parse(checkUpdates) == 1 && mounted) {
      setState(() {
        _initiateUpdateCheck = true;
      });
    }
  }

  void _initializeWebView() {
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            _initializeWhiteListedDomains();
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            if (_switchModeOnFullscreen) {
              _injectListnerMethod();
            }
            _hideHeader();
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            Uri uri = Uri.parse(request.url);
            String domain = uri.host;

            if (_isWhitelisted(domain)) {
              return NavigationDecision.navigate;
            }

            _showSnackBarMessage('$domain Blocked.', url: uri);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..addJavaScriptChannel(
        'OrientationChange',
        onMessageReceived: (JavaScriptMessage message) {
          _toggleOrientation(message.message.toLowerCase() == 'true');
        },
      );
    setState(() {
      _webViewController = controller;
      // _webViewController.loadRequest(Uri.parse(_homepage));
      _isWebviewloaded = true;
    });
  }

  Future<void> _refreshConfigurationValues() async {
    bool landscapeOnFullscreen = true;
    String? landscapeOnFullscreenVal =
        await dbService.getConfigurationValue('landscape_on_fullscreen');
    if (landscapeOnFullscreenVal != null) {
      landscapeOnFullscreen = int.parse(landscapeOnFullscreenVal) == 1;
    }

    String? homepageConfig = await dbService.getActiveHomePageUrl();
    if (homepageConfig != null &&
        homepageConfig != '' &&
        _homepage != homepageConfig) {
      _homepage = homepageConfig;
      setState(() {
        if (_isWebviewloaded) {
          _webViewController.loadRequest(Uri.parse(_homepage));
        }
      });
    } else if (homepageConfig == null || homepageConfig == '') {
      _homepage = getHomePageNotConfiguredWebPage();
      setState(() {
        if (_isWebviewloaded) {
          _webViewController.loadRequest(Uri.parse(_homepage));
        }
      });
    }

    setState(() {
      _switchModeOnFullscreen = landscapeOnFullscreen;
    });
  }

  Future<void> _loadVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  void _injectListnerMethod() async {
    String eventListnerScript = '''
            document.addEventListener('fullscreenchange', (event) => {
              if(document.fullscreenElement) {
                OrientationChange.postMessage("true");
              } else {
                OrientationChange.postMessage("false");
              }
            });
      ''';
    await _webViewController.runJavaScript(eventListnerScript);
  }

  void _hideHeader() async {
    String script;
    script = '''
        var headerElements = document.querySelectorAll("[class*='header']");
        if(headerElements.length > 0) {
          headers.forEach(header => {
              header.style.display = 'none';
          });
        }
      ''';

    await _webViewController.runJavaScript(script);
  }

  void _showSnackBarMessage(String message, {Uri? url}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(message),
            if (url != null)
              Tooltip(
                message: 'Whitelist ${url.host}.',
                child: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    _saveWhitlistedDomain(url);
                  },
                  color: Colors.white,
                ),
              )
          ],
        ),
        duration: url != null ? const Duration(seconds: 2) : Durations.long2,
      ),
    );
  }

  void _toggleOrientation(switchToLandscape) {
    if (switchToLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  bool _isWhitelisted(String url) {
    return whiteListedDomains.any((domain) => url.contains(domain));
  }

  void _onClearCache() async {
    await _webViewController.clearCache();
    await _webViewController.clearLocalStorage();
    _showSnackBarMessage('Cache cleared.');
  }

  Future<void> _initializeWhiteListedDomains() async {
    List<String> domains = [];

    var data = await dbService.getData('whitelisted_domain');
    if (data.isNotEmpty) {
      domains = data.map((map) {
        return map['text'] as String;
      }).toList();
    }

    setState(() {
      whiteListedDomains = domains;
    });
  }

  void _saveWhitlistedDomain(Uri uri) async {
    _showSnackBarMessage('${uri.host} whitelisted.');
    await dbService.insertDomain(uri.host, homePage: _homepage);
    await _initializeWhiteListedDomains();
    _webViewController.loadRequest(uri);
  }

  Widget _loadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/loading.gif',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          const Text(
            "Loading...",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _refreshConfigandDomains() async {
    await Future.wait([
      _refreshConfigurationValues(),
      _initializeWhiteListedDomains(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        title: const Text('XStream'),
        actions: [
          IconButton(
            icon: const Icon(Icons.screen_rotation_sharp),
            onPressed: () {
              final orientation = MediaQuery.of(context).orientation;
              _toggleOrientation(orientation == Orientation.portrait);
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MatchSchedulePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
      drawer: Builder(builder: (context) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'XStream',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version $_version',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Icon(Icons.settings), Text('Settings')],
                ),
                onTap: () {
                  Scaffold.of(context).closeDrawer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  ).then((value) {
                    _refreshConfigandDomains();
                  });
                },
              ),
              ListTile(
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Icon(Icons.help_outline_sharp), Text('Help')],
                ),
                onTap: () async {
                  Scaffold.of(context).closeDrawer();

                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  String repoUrl = 'https://xstream--app.web.app';
                  Uri url = Uri.parse(repoUrl);
                  if (await canLaunchUrl(url)) {
                    launchUrl(url);
                  } else {
                    Clipboard.setData(ClipboardData(text: repoUrl));
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                          content: Text('Repository copied to clipboard')),
                    );
                  }
                },
              ),
              ListTile(
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.free_cancellation_sharp),
                    Text('Clear browser cache')
                  ],
                ),
                onTap: () {
                  _onClearCache();
                  Scaffold.of(context).closeDrawer();
                },
              ),
              ListTile(
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Icon(Icons.phone_android), Text('About app')],
                ),
                onTap: () {
                  Scaffold.of(context).closeDrawer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                },
              ),
            ],
          ),
        );
      }),
      body: !_isWebviewloaded
          ? _loadingWidget()
          : PopScope(
              canPop: false,
              onPopInvokedWithResult: (bool didPop, Object? result) async {
                if (didPop) {
                  return;
                }
                final bool canGoBack = await _webViewController.canGoBack();
                if (canGoBack) {
                  _webViewController.goBack();
                  return;
                }
                if (context.mounted) {
                  SystemNavigator.pop();
                }
              },
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_isLoading) _loadingWidget(),
                  if (_initiateUpdateCheck)
                    AppUpdateWidget(
                      onUpdateComplete: () {
                        // Handle update completion
                        setState(() {
                          _initiateUpdateCheck = false;
                        });
                      },
                    ),
                  const DonatePage(),
                ],
              )),
      bottomNavigationBar: _isWebviewloaded
          ? NavigationControls(
              webViewController: _webViewController,
              uri: Uri.parse(_homepage),
            )
          : null,
    );
  }
}
