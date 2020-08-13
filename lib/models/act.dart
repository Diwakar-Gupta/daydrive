import 'dart:async';
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


class TimeDate {
  int date; //YYYYMMDD
  int time; //HHMM

  TimeDate({this.date, this.time});

  static create({int year, int month, day, hour, min}) {
    int date = year * 10000 + month * 100 + day;
    int time = hour * 100 + min;
    return TimeDate(time: time, date: date);
  }

  static TimeDate now() {
    var dt = DateTime.now();
    int date = 0;
    int time = 0;

    date = dt.year * 10000 + dt.month * 100 + dt.day;
    time = dt.hour * 100 + dt.minute;
    return TimeDate(time: time, date: date);
  }

  int day(){
    return date%100;
  }
  int month(){
    return (date~/100)%100;
  }
  int year(){
    return (date~/10000);
  }
  int hour(){
    return time~/100;
  }
  int min(){
    return time%100;
  }
}

/*
CREATE TABLE "act" (
	"pk"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	"name"	TEXT NOT NULL,
	"sdes"	TEXT NOT NULL,
	"starttime"	INTEGER,
	"startdate"	INTEGER,
	"edes"	INTEGER,
	"endtime"	INTEGER,
	"enddate"	INTEGER
);
*/
// take in range // SELECT * FROM act WHERE starttime >= 20200311 AND starttime <= 20200312;
class Act {
  int pk;
  String name;
  String sdes, edes;

  TimeDate starttime;
  TimeDate endtime= TimeDate(time: 0, date:0);

  Act(
      {this.name,
      this.sdes = "",
      this.starttime,
      this.edes="",
      this.endtime,
      this.pk = 0});

  static Future<Act> create({String name, String sdes}) async {
    var obj = Act(name: name, sdes: sdes, starttime: TimeDate.now());
    await obj.insert();
    return obj;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sdes': sdes,
      'starttime': starttime.time,
      'startdate': starttime.date,
      'edes':edes,
      'endtime':endtime.time,
      'enddate':endtime.date,
    };
  }

  Future<void> insert() async {
    // Get a reference to the database.
    final Database _db = await database;
    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    print("inserting act");
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
        sdes: maps[i]['des'],
        starttime: TimeDate(time:maps[i]['starttime'], date:maps[i]['startdate']),
        edes:maps[i]['edes'],
        endtime: TimeDate(time:maps[i]['endtime'], date:maps[i]['enddate']),
        
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
    return 'Act{pk: $pk, name: $name des: $sdes}';
  }
}
