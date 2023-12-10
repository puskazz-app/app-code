import 'dart:io';
import 'dart:developer';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:puskazz_app/Utils/Cheats/SaveModel.dart';
import 'package:sqflite/sqflite.dart';

class CheatsDBhelper {
  CheatsDBhelper._privateConstructor();
  static final CheatsDBhelper instance = CheatsDBhelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
    }

    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, 'cheatsdb.db');
    log(path);
    var saves = await openDatabase(path, version: 1, onCreate: _onCreate);
    return saves;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cheatsdb (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        savedCheatTitle TEXT,
        savedCheatImages TEXT
      )
    ''');
  }

  Future<List<CheatsModel>> getSettings() async {
    final Database db = await database;
    final List<Map<String, dynamic>> saves = await db.query('cheatsdb');
    return List.generate(saves.length, (i) {
      return CheatsModel(
        id: saves[i]['id'],
        savedCheatTitle: saves[i]['savedCheatTitle'],
        savedCheatImages: saves[i]['savedCheatImages'],
      );
    });
  }

  Future<int> add(CheatsModel save) async {
    Database db = await instance.database;
    var result = await db.insert('cheatsdb', save.toMap());
    return result;
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    var result = await db.delete('cheatsdb', where: 'id = ?', whereArgs: [id]);
    return result;
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    var result = await db.delete('cheatsdb');
    return result;
  }

  Future<int> update(CheatsModel save) async {
    Database db = await instance.database;
    var result = await db.update('cheatsdb', save.toMap(),
        where: 'id = ?', whereArgs: [save.id]);
    return result;
  }

  Future<List<CheatsModel>> search(String query) async {
    Database db = await instance.database;
    var result = await db.query('cheatsdb',
        where: 'savedCheatTitle LIKE ?', whereArgs: ['%$query%']);
    return result.map((item) => CheatsModel.fromMap(item)).toList();
  }
}
