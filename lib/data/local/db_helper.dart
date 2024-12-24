import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  //singleton
  DBHelper._(); //privatization constructor because if underscore
  static final DBHelper getInstance = DBHelper._();

  //table note
  static final String TABLE_NOTE = "note";
  static final String COLUMN_NOTE_SNO = "s_no";
  static final String COLUMN_NOTE_TITLE = "title";
  static final String COLUMN_NOTE_DESC = "desc";

  Database? myDB; //? means that it can be null.

  //db open (path->exist then open else create db).
  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;
    // if (myDB != null) {
    //   return myDB!;
    // } else {
    //   myDB=await openDB();
    //   return myDB!;
    // }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB.db");
    return await openDatabase(dbPath, onCreate: (db, version) {
      //create all your tables here
      db.execute(
          "create table $TABLE_NOTE ($COLUMN_NOTE_SNO integer primary key autoincrement,$COLUMN_NOTE_TITLE text,$COLUMN_NOTE_DESC text)");
      // you can create any number of table above query
    }, version: 1);
  }

  // all queries

  //insertion
Future<bool> addNote({required String mTitle,required String mDesc}) async{
    var db = await getDB();
    int rowsAffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE:mTitle,
      COLUMN_NOTE_DESC:mDesc
    });
    return rowsAffected>0;
}

// reading all data
Future<List<Map<String,dynamic>>> getAllNotes() async{
    var db = await getDB();
    //select * from note is meaning of code below
    List<Map<String, dynamic>> mdata = await db.query(TABLE_NOTE,);
    return mdata;
}

//update data
Future<bool> updateNote({required String mTitle,required String mDesc,required int s_no}) async{
    var db = await getDB();

    int rowsAffected = await db.update(TABLE_NOTE, {
      COLUMN_NOTE_TITLE:mTitle,
      COLUMN_NOTE_DESC:mDesc
    },where: "$COLUMN_NOTE_SNO=$s_no");
    return rowsAffected>0;
}

//delete

Future<bool> deleteNote({required int s_no}) async{
    var db = await getDB();
    int rowsAffected = await db.delete(TABLE_NOTE,where: "$COLUMN_NOTE_SNO = ?", whereArgs: ["$s_no"]);
    return rowsAffected>0;
}

}
