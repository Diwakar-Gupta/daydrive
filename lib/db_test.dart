import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  final path = join(await getDatabasesPath(), 'database2.db');

  await deleteDatabase(path);

  return openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    // When the database is first created, create a table to store dogs.
    path,
    onCreate: (db, version) {
      db.execute(
        'CREATE TABLE datetime (pk	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,	year	INTEGER NOT NULL,	"month"	INTEGER NOT NULL,	"date"	INTEGER NOT NULL,	"hour"	INTEGER NOT NULL,	"min"	INTEGER NOT NULL);',
      );
      db.execute(
        'CREATE TABLE act (	"pk"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,	"name"	TEXT NOT NULL,	"des"	TEXT NOT NULL,	"starttime"	INTEGER NOT NULL,	"endtime"	INTEGER);',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}

Future<Database> database = main();

/*
CREATE TABLE "datetime" (
	"pk"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	"year"	INTEGER NOT NULL,
	"month"	INTEGER NOT NULL,
	"date"	INTEGER NOT NULL,
	"hour"	INTEGER NOT NULL,
	"min"	INTEGER NOT NULL
);
*/
class DateTime {
  int year;
  int month;
  int date;
  int hour;
  int min;
  int pk;

  DateTime(
      {this.year, this.month, this.date, this.hour, this.min, this.pk = 0});

  static Future<DateTime> create(
      {int year, int month, int date, int hour, int min}) async {
    var obj =
        DateTime(year: year, month: month, date: date, hour: hour, min: min);
    await obj.insert();
    return obj;
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'date': date,
      'hour': hour,
      'min': min,
    };
  }

  Future<void> insert() async {
    // Get a reference to the database.
    final Database _db = await database;
    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    print("inserting DateTime");
    pk = await _db.insert(
      'datetime',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<DateTime>> all() async {
    // Get a reference to the database.
    final Database _db = await database;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await _db.query('datetime');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    print("all DateTime");
    return List.generate(maps.length, (i) {
      return DateTime(
        year: maps[i]['year'],
        month: maps[i]['month'],
        date: maps[i]['date'],
        hour: maps[i]['hour'],
        min: maps[i]['min'],
        pk: maps[i]['pk'],
      );
    });
  }

  Future<void> update() async {
    // Get a reference to the database.
    final Database _db = await database;
    // Update the given Dog.
    print("updating DateTime");
    await _db.update(
      'datetime',
      toMap(),
      // Ensure that the Dog has a matching id.
      where: "pk = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [pk],
    );
  }

  Future<void> delete() async {
    // Get a reference to the database.
    final Database _db = await database;
    // Remove the Dog from the database.
    print("deleting dog");
    await _db.delete(
      'datetime',
      // Use a `where` clause to delete a specific dog.
      where: "pk = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [pk],
    );
  }
}

/*
CREATE TABLE "act" (
	"pk"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	"name"	TEXT NOT NULL,
	"des"	TEXT NOT NULL,
	"starttime"	INTEGER NOT NULL,
	"endtime"	INTEGER
);
*/
class Act {
  int pk;
  String name;
  String des;
  int starttime;
  int endtime;

  Act({this.name, this.des = "", this.starttime, this.pk = 0});

  static Future<Act> create({String name, String des}) async {
    var time =
        await DateTime.create(year: 3, month: 3, min: 3, hour: 3, date: 3);

    var obj = Act(name: name, des: des, starttime: time.pk);
    await obj.insert();
    return obj;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'des': des,
      'starttime': starttime,
      if (pk != 0) 'pk': pk
    };
  }

  Future<void> insert() async {
    // Get a reference to the database.
    final Database _db = await database;
    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    print("inserting dog");
    pk = await _db.insert(
      'act',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Act>> all() async {
    // Get a reference to the database.
    final Database _db = await database;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await _db.query('act');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    print("all dog");
    
    return List.generate(maps.length, (i) {
      print(maps[i]['name'].runtimeType);
      print(maps[i]['des'].runtimeType);
      print(maps[i]['starttime'].runtimeType);
      print(maps[i]['pk'].runtimeType);
      
      return Act(
        name: maps[i]['name'],
        des: maps[i]['des'],
        starttime: maps[i]['starttime'],
        pk: maps[i]['pk'],
      );
    });
  }

  Future<void> update() async {
    // Get a reference to the database.
    final Database _db = await database;
    // Update the given Dog.
    print("updating dog");
    await _db.update(
      'act',
      toMap(),
      // Ensure that the Dog has a matching id.
      where: "pk = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [pk],
    );
  }

  Future<void> delete() async {
    // Get a reference to the database.
    final Database _db = await database;
    // Remove the Dog from the database.
    print("deleting dog");
    await _db.delete(
      'act',
      // Use a `where` clause to delete a specific dog.
      where: "pk = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [pk],
    );
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Act{pk: $pk, name: $name des: $des}';
  }
}
