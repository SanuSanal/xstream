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
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE home_page(id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT, active BOOLEAN)",
        );

        await db.execute(
          "CREATE TABLE whitelisted_domain(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT)",
        );

        await db.execute(
          "ALTER TABLE whitelisted_domain ADD COLUMN home_page_id TEXT",
        );

        await db.execute(
          "CREATE TABLE configurations(id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value Text)",
        );

        await db.insert(
            'configurations', {'key': 'landscape_on_fullscreen', 'value': '1'});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("DELETE FROM whitelisted_domain");
          await db.execute(
            "ALTER TABLE whitelisted_domain ADD COLUMN home_page_id TEXT",
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getData(String tableName) async {
    final db = await database;
    return db.query(tableName);
  }

  Future<void> insertDomain(String domain,
      {int? homePageId, String? homePage}) async {
    if (homePageId == null && homePage == null) {
      throw ArgumentError('Either homePageId or homePage must be provided.');
    }

    final db = await database;

    List<Map<String, dynamic>> existing = await db.query(
      'whitelisted_domain',
      where: 'text = ?',
      whereArgs: [domain],
    );

    if (homePageId == null) {
      List<Map<String, dynamic>> homePageEntity = await db.query('home_page',
          columns: ['id'], where: 'url = ?', whereArgs: [homePage]);
      homePageId = homePageEntity[0]['id'];
    }

    if (existing.isEmpty) {
      await db.insert(
          'whitelisted_domain', {'text': domain, 'home_page_id': homePageId});
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

      int id = await db.insert('home_page', {'url': url, 'active': 0});
      await insertDomain(domain, homePageId: id);
    }
  }

  Future<void> deleteDomain(int id) async {
    final db = await database;
    await db.delete('whitelisted_domain', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteStreamSite(int id) async {
    final db = await database;
    await db.delete('whitelisted_domain',
        where: 'home_page_id = ?', whereArgs: [id]);
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
