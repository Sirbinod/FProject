import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../Model/friend.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String friendTable = 'friend_table';
  String colId = 'id';
  String colName = 'name';
  String colNumber = 'number';
  String colDate = 'date';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'friends.db';

    // Open/create the database at a given path
    var friendsDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return friendsDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $friendTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT, '
        '$colNumber TEXT, $colDate TEXT)');
  }

  // Fetch Operation: Get all todo objects from database
  Future<List<Map<String, dynamic>>> getFriendMapList() async {
    Database db = await this.database;

    //var result = await db.rawQuery('SELECT * FROM $friendTable order by $colName ASC');
    var result = await db.query(friendTable, orderBy: '$colName ASC');
    return result;
  }

  // Insert Operation: Insert a todo object to database
  Future<int> insertFriend(Friend friend) async {
    Database db = await this.database;
    var result = await db.insert(friendTable, friend.toMap());
    return result;
  }

  // Update Operation: Update a todo object and save it to database
  Future<int> updateFriend(Friend friend) async {
    var db = await this.database;
    var result = await db.update(friendTable, friend.toMap(),
        where: '$colId = ?', whereArgs: [friend.id]);
    return result;
  }

  // Delete Operation: Delete a todo object from database
  Future<int> deleteFriend(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $friendTable WHERE $colId = $id');
    return result;
  }

  // Get number of todo objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $friendTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'todo List' [ List<Todo> ]
  Future<List<Friend>> getFriendList() async {
    var friendMapList =
        await getFriendMapList(); // Get 'Map List' from database
    int count =
        friendMapList.length; // Count the number of map entries in db table

    List<Friend> friendList = List<Friend>();
    // For loop to create a 'todo List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      friendList.add(Friend.fromMapObject(friendMapList[i]));
    }

    return friendList;
  }
}
