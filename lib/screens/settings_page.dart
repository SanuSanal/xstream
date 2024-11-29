import 'package:flutter/material.dart';
import 'package:xstream/model/configuration_model.dart';
import 'package:xstream/service/database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final dbService = DatabaseService();
  List<Configuration> _configurations = [];
  List<Map<String, dynamic>> _whitelistedDomains = [];
  List<Map<String, dynamic>> _homePages = [];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _refreshConfigurations();
    _refreshDomainList();
    _refreshSiteList();
  }

  Future<void> _refreshConfigurations() async {
    final configurationsFromDb = await dbService.getData('configurations');

    final configurationList = List.generate(configurationsFromDb.length, (i) {
      return Configuration.fromMap(configurationsFromDb[i]);
    });
    setState(() {
      _configurations = configurationList;
    });
  }

  Future<void> _refreshDomainList() async {
    final domains = await dbService.getData('whitelisted_domain');
    setState(() {
      _whitelistedDomains = domains;
    });
  }

  Future<void> _refreshSiteList() async {
    final homePages = await dbService.getData('home_page');
    setState(() {
      _homePages = homePages;
    });
  }

  Future<void> _deleteDomain(int id) async {
    await dbService.deleteDomain(id);
    _refreshDomainList();
  }

  Future<void> _showAddStreamSiteDialog(BuildContext context) async {
    final TextEditingController urlController = TextEditingController();
    bool isUrlValid = true;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add Stream Site',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        labelText: 'Stream site URL',
                        errorText:
                            isUrlValid ? null : 'Please enter a valid URL',
                      ),
                      keyboardType: TextInputType.url,
                      autofocus: true,
                      onChanged: (value) {
                        if (!isUrlValid) {
                          setState(() {
                            isUrlValid = true;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            final url = urlController.text.trim();
                            if (_isValidUrl(url)) {
                              _saveStreamSite(url);
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                isUrlValid = false;
                              });
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  bool _isValidUrl(String url) {
    const urlPattern =
        r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}(:[0-9]{1,5})?(\/.*)?$';
    return RegExp(urlPattern).hasMatch(url);
  }

  void _saveStreamSite(String url) async {
    await dbService.insertStreamSite(url);

    await Future.wait([
      _refreshSiteList(),
      _refreshDomainList(),
    ]);

    if (mounted) {
      _showSnackBarMessage(context, '$url saved.');
    }
  }

  Widget _getWhitelistedDomainsForSite(int homePageId) {
    var domains = _whitelistedDomains
        .where((domain) => int.parse(domain['home_page_id']) == homePageId)
        .toList();

    return Column(
      children: [
        const SizedBox(height: 15.0),
        if (domains.isNotEmpty)
          const Text(
            "Whitelisted Domains",
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        domains.isEmpty
            ? const Center(child: Text('No whitelisted domains available'))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: domains.length,
                itemBuilder: (context, index) {
                  final domainItem = domains[index];
                  final id = domainItem['id'];
                  final text = domainItem['text'];

                  return Container(
                    margin: const EdgeInsets.only(left: 13),
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 0.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            text,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showSnackBarMessage(context, '$text deleted.');
                            _deleteDomain(id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _configurations.isEmpty
                ? const Center()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _configurations.length,
                    itemBuilder: (context, index) {
                      final configuration = _configurations[index];

                      switch (configuration.key) {
                        case 'landscape_on_fullscreen':
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 16.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Landscape on fullscreen',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                                Switch(
                                  value: int.parse(_getConfigurationValue(
                                          'landscape_on_fullscreen')) ==
                                      1,
                                  onChanged: (bool value) {
                                    _showSnackBarMessage(context,
                                        'Configuration updated. $value');
                                    _updateConfigurationValue(
                                        'landscape_on_fullscreen',
                                        value ? 1 : 0);
                                  },
                                ),
                              ],
                            ),
                          );
                        case 'auto_update':
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 16.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Auto-check updates',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                                Switch(
                                  value: int.parse(_getConfigurationValue(
                                          'auto_update')) ==
                                      1,
                                  onChanged: (bool value) {
                                    _showSnackBarMessage(
                                        context, 'Configuration updated.');
                                    _updateConfigurationValue(
                                        'auto_update', value ? 1 : 0);
                                  },
                                ),
                              ],
                            ),
                          );
                        default:
                          return const Center(
                            child: Text('X'),
                          );
                      }
                    },
                  ),

            // Stream sites section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Streaming sites',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await _showAddStreamSiteDialog(context);
                    },
                  ),
                ],
              ),
            ),
            _homePages.isEmpty
                ? const Center(child: Text('No stream sites available'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _homePages.length,
                    itemBuilder: (context, index) {
                      final streamItem = _homePages[index];
                      final id = streamItem['id'];
                      final url = streamItem['url'];
                      final bool isActive = streamItem['active'] as int == 1;
                      final bool isExpanded = _selectedIndex == index;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 0.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_down
                                        : Icons.keyboard_arrow_right,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedIndex =
                                          isExpanded ? null : index;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    url,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.check_circle_rounded,
                                        color: isActive
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        _showSnackBarMessage(
                                            context, '$url activated.');
                                        _activateStreamSite(id);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _showSnackBarMessage(
                                            context, '$url deleted.');
                                        _deleteStreamSite(id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (isExpanded) _getWhitelistedDomainsForSite(id)
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showSnackBarMessage(BuildContext context, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Durations.long4,
      ),
    );
  }

  void _activateStreamSite(id) async {
    await dbService.setActiveStreamSite(id);
    setState(() {
      _refreshSiteList();
    });
  }

  void _deleteStreamSite(id) async {
    await dbService.deleteStreamSite(id);
    setState(() {
      _refreshSiteList();
      _refreshDomainList();
    });
  }

  String _getConfigurationValue(String s) {
    if (_configurations.isNotEmpty) {
      return _configurations.where((c) => c.key == s).first.value;
    }
    return '';
  }

  void _updateConfigurationValue(String key, int value) async {
    await dbService.updateConfiguration(key, value);
    await _refreshConfigurations();
  }
}
