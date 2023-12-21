import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UsersDB {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initializeDB();
      return _db;
    } else {
      return _db;
    }
  }

  initializeDB() async {
    print("Initialize================");
    String myPath = await getDatabasesPath();
    String DBPath = join(myPath, 'drivers.db');
    Database mydb = await openDatabase(
      DBPath,
      version: 1,
      onCreate: (db, version) async {
        db.execute('''
        CREATE TABLE 'Users' (
          'ID' TEXT NOT NULL PRIMARY KEY ,
          'email' TEXT NOT NULL,
          'firstName' TEXT NOT NULL,
          'lastName' TEXT NOT NULL,
          'phone' TEXT NOT NULL
        )
     
        ''');
      },
    );
    return mydb;
  }

  readData(String sql) async {
    Database? myDb = await db;
    List<Map> response = await myDb!.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Database? myDb = await db;
    int response = await myDb!.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Database? myDb = await db;
    int response = await myDb!.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    Database? myDb = await db;
    var response = myDb!.rawDelete(sql);
    return response;
  }

}
