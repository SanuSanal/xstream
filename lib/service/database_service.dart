import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'data.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE home_page(id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT, active BOOLEAN)",
        );

        await db.insert(
            'home_page', {'url': 'https://soccerlive.app/', 'active': 1});
        await db.insert(
            'home_page', {'url': 'https://www.crictime.com', 'active': 0});
        await db.insert(
            'home_page', {'url': 'https://www.webcric.com', 'active': 0});
        await db.insert(
            'home_page', {'url': 'https://me.webcric.com/', 'active': 0});

        await db.execute(
          "CREATE TABLE whitelisted_domain(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT)",
        );

        await db.insert('whitelisted_domain', {'text': 'soccerlive'});
        await db.insert('whitelisted_domain', {'text': 'streameast'});
        await db.insert('whitelisted_domain', {'text': '1stream'});
        await db.insert('whitelisted_domain', {'text': 'methstreams'});
        await db.insert('whitelisted_domain', {'text': 'methstreamer'});
        await db.insert('whitelisted_domain', {'text': 'buffstreams'});
        await db.insert('whitelisted_domain', {'text': 'soccerstreamlinks'});
        await db.insert('whitelisted_domain', {'text': 'vivosoccer'});
        await db.insert('whitelisted_domain', {'text': 'weakspell'});
        await db.insert('whitelisted_domain', {'text': 'elixx'});
        await db.insert('whitelisted_domain', {'text': 'gameshdlive'});

        await db.execute(
          "CREATE TABLE configurations(id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value Text)",
        );

        await db.insert(
            'configurations', {'key': 'landscape_on_fullscreen', 'value': '1'});
      },
      version: 1,
    );
  }

  Future<List<Map<String, dynamic>>> getData(String tableName) async {
    final db = await database;
    return db.query(tableName);
  }

  Future<void> insertDomain(String domain) async {
    final db = await database;

    List<Map<String, dynamic>> existing = await db.query(
      'whitelisted_domain',
      where: 'text = ?',
      whereArgs: [domain],
    );

    if (existing.isEmpty) {
      await db.insert('whitelisted_domain', {'text': domain});
    }
  }

  Future<void> insertStreamSite(String url) async {
    final db = await database;

    List<Map<String, dynamic>> existing = await db.query(
      'home_page',
      where: 'url = ?',
      whereArgs: [url],
    );

    if (existing.isEmpty) {
      Uri uri = Uri.parse(url);
      String domain = uri.host;

      await db.insert('home_page', {'url': url, 'active': 0});
      await insertDomain(domain);
    }
  }

  Future<void> deleteDomain(int id) async {
    final db = await database;
    await db.delete('whitelisted_domain', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteStreamSite(int id) async {
    final db = await database;
    await db.delete('home_page', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setActiveStreamSite(int id) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.update(
        'home_page',
        {'active': 0},
        where: 'active = ?',
        whereArgs: [1],
      );

      await txn.update(
        'home_page',
        {'active': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<String?> getActiveHomePageUrl() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'home_page',
      where: 'active = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['url'] as String;
    }

    return null;
  }

  updateConfiguration(String key, int value) async {
    final db = await database;

    db.update(
      'configurations',
      {'value': value},
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<String?> getConfigurationValue(String key) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> result = await db.query(
        'configurations',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first['value'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
