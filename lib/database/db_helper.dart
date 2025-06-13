import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  // DBHelper는 앱 내에서 단 하나의 인스턴스만 사용하도록 싱글톤 생성
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  // getter
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath(); // 기본경로
    final path = join(dbPath, 'my_texts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE texts (
            seq INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            createdAt TEXT,
            modifiedAt TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertText(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('texts', row);
  }

  Future<List<Map<String, dynamic>>> getTextsList() async {
    final db = await database;
    return await db.query('texts', orderBy: 'seq DESC');
  }

  Future<int> updateText(int seq, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('texts', row, where: 'seq = ?', whereArgs: [seq]);
  }

  Future<int> deleteText(int seq) async {
    final db = await database;
    return await db.delete('texts', where: 'seq = ?', whereArgs: [seq]);
  }

  // 어플 종료 시 DB연결 종료.
  Future close() async {
    final db = await database;
    db.close();
  }

}
