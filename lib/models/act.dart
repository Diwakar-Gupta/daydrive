import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  final path = join(await getDatabasesPath(), 'database2.db');

  // await deleteDatabase(path);

  return openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    // When the database is first created, create a table to store dogs.
    path,
    onCreate: (db, version) {
      db.execute(
          'CREATE TABLE "act" (	"pk"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,	"name"	TEXT NOT NULL,	"sdes"	TEXT NOT NULL,	"startdatetime"	INTEGER,	"edes"	INTEGER,	"enddatetime"	INTEGER);');
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}

Future<Database> database = main();

class TimeDate {
  int datetime; //YYYYMMDDHHMM

  TimeDate({this.datetime});

  static create({int year, int month, day, hour, min}) {
    int datetime =
        year * 100000000 + month * 1000000 + day * 10000 + hour * 100 + min;
    return TimeDate(datetime: datetime);
  }

  static TimeDate from(DateTime dt) {
    return create(
        year: dt.year,
        month: dt.month,
        day: dt.day,
        hour: dt.hour,
        min: dt.minute);
  }

  static TimeDate now() {
    return from(DateTime.now());
  }

  int year() {
    return (datetime % 1000000000000) ~/ 100000000;
  }

  int month() {
    return (datetime % 100000000) ~/ 1000000;
  }

  int day() {
    return (datetime % 1000000) ~/ 10000;
  }

  int hour() {
    return (datetime % 10000) ~/ 100;
  }

  int min() {
    return datetime % 100;
  }
}

/*
CREATE TABLE "act" (
  	"pk"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
    "name"	TEXT NOT NULL,	
    "sdes"	TEXT NOT NULL,	
    "startdatetime"	INTEGER,	
    "edes"	INTEGER,	
    "enddatetime"	INTEGER
  );
*/
// take in range // SELECT * FROM act WHERE starttime >= 20200311 AND starttime <= 20200312;
class Act {
  int pk;
  String name;
  String sdes, edes;

  TimeDate startdatetime;
  TimeDate enddatetime = TimeDate(datetime: 0);

  Act(
      {this.name,
      this.sdes = "",
      this.startdatetime,
      this.edes = "",
      this.enddatetime,
      this.pk = 0});

  static Act from(Map map) {
    var pk = map['pk'];
    var name = map['name'];
    var sdes = map['sdes'];
    var startdatetime = TimeDate(datetime:map['startdatetime']);
    var edes = '';
    if (map.containsKey('edes')) edes = map['edes'];
    var enddatetime = TimeDate(datetime:map['enddatetime']);
    return Act(
        name: name,
        sdes: sdes,
        startdatetime: startdatetime,
        edes: edes,
        enddatetime: enddatetime,
        pk: pk);
  }

  Future<bool> done(String des, TimeDate endtime) async {
    this.edes = des;
    this.enddatetime = endtime;
    await update();
    return true;
  }

  static Future<Act> create({String name, String sdes}) async {
    var obj = Act(name: name, sdes: sdes, startdatetime: TimeDate.now());
    await obj.insert();
    return obj;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sdes': sdes,
      'startdatetime': startdatetime.datetime,
      'edes': edes,
      'enddatetime': enddatetime.datetime,
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

  static Future<List<Act>> inRange({TimeDate from, TimeDate to, bool or}) async {
    final Database db = await database;
    var args = [];
    String filter = "";
    if (from == null && to == null) {
      filter = '1==1';
    } else {
      if (from != null) {
        filter += 'startdatetime >= ?';
        args.add(from.datetime);
      }
      if (to != null) {
        if (filter.length > 0) filter += or? ' OR ' : ' AND ';
        filter += 'enddatetime <= ?';
        args.add(to.datetime);
      }
    }
    final List<Map<String, dynamic>> maps =
        await db.query('act', where: filter, whereArgs: args, orderBy: 'pk');

    var d = List<Act>.generate(maps.length, (index) {
      return Act.from(maps[index]);
    });
    return d;
  }

  static Future<List<Act>> all() async {
    // Get a reference to the database.
    final Database _db = await database;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await _db.query('act');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    print("all dog");

    return List.generate(maps.length, (i) {
      return Act(
        name: maps[i]['name'],
        sdes: maps[i]['des'],
        startdatetime: TimeDate(datetime: maps[i]['starttime']),
        edes: maps[i]['edes'],
        enddatetime: TimeDate(datetime: maps[i]['endtime']),
        pk: maps[i]['pk'],
      );
    });
  }

  Future<void> update() async {
    // Get a reference to the database.
    final Database _db = await database;
    // Update the given Dog.
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
