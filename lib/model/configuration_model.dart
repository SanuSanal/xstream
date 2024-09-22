class Configuration {
  int id;
  String key;
  String value;

  Configuration({required this.id, required this.key, required this.value});

  factory Configuration.fromMap(Map<String, dynamic> map) {
    return Configuration(
      id: map['id'],
      key: map['key'],
      value: map['value'].toString(),
    );
  }
}
