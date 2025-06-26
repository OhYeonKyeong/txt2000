import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:txt2000/models/text_model.dart';


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
    final dbPath = await getDatabasesPath();
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

  // 저장하기
  // 모오델을 사용하지 않으면 여기가 insertText(Map<String, dynamic>) async { 이렇게된다!
  Future<int> insertText(TextModel text) async {
    final db = await database;
    return await db.insert('texts', text.toMap());
  }

  // 글목록 불러오기
  Future<List<TextModel>> getTextsList() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT seq, title, content, createdAt, modifiedAt
      FROM texts
      ORDER BY seq DESC
    ''');

    return result.map((row) => TextModel.fromMap(row)).toList();
  }

  // 글상세 불러오기
  Future<TextModel?> getTextBySeq(int seq) async {
    final db = await database;
    final result = await db.query(
      'texts',
      where: 'seq = ?',
      whereArgs: [seq],
    );

    if (result.isNotEmpty) {
      return TextModel.fromMap(result.first);
    }

    return null;
  }
  
  // 수정하기
  Future<int> updateText(TextModel text) async {
    final db = await database;
    return await db.update(
      'texts',
      text.toMap(),
      where: 'seq = ?',
      whereArgs: [text.seq],
    );
  }

  // 삭제하기
  Future<int> deleteText(int seq) async {
    final db = await database;
    return await db.delete('texts', where: 'seq = ?', whereArgs: [seq]);
  }

  // 어플 종료 시 DB연결 종료.
  Future<void> close() async {
    final db = await database;
    db.close();
  }

}
