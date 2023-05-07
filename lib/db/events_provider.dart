import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import '../model/model.dart';
import '../model/model_constant.dart';

//for CSV ?
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../model/nameday_constant.dart';

DbEvent snapshotToEvent(Map<String, Object?> snapshot) {
  return DbEvent()..fromMap(snapshot);
}

class DbEvents extends ListBase<DbEvent> {
  final List<Map<String, Object?>> list;
  late List<DbEvent?> _cacheEvents;

  DbEvents(this.list) {
    _cacheEvents = List.generate(list.length, (index) => null);
  }

  @override
  DbEvent operator [](int index) {
    return _cacheEvents[index] ??= snapshotToEvent(list[index]);
  }

  @override
  int get length => list.length;

  @override
  void operator []=(int index, DbEvent? value) => throw 'read-only';

  @override
  set length(int newLength) => throw 'read-only';
}

class DbEventsProvider {
  final lock = Lock(reentrant: true);
  final DatabaseFactory dbFactory;
  final _updateTriggerController = StreamController<bool>.broadcast();
  Database? db;

  DbEventsProvider(this.dbFactory);

  Future openPath(String path) async {
    db = await dbFactory.openDatabase(path,
        options: OpenDatabaseOptions(
            version: kVersion1,
            onCreate: (db, version) async {
              await _createDb(db);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < kVersion1) {
                await _createDb(db);
              }
            }));
  }

  void _triggerUpdate() {
    _updateTriggerController.sink.add(true);
  }

  Future<Database?> get ready async => db ??= await lock.synchronized(() async {
        if (db == null) {
          await open();
        }
        return db;
      });


//GET CELEBRATION FROM ID
  Future<DbEvent?> getEvent(int? id) async {
    var list = (await db!.query(tableEvents,
        columns: [
          columnId,
          columnFirstName,
          columnLastName,
          columnIdeas,
          columnUpdated,
          columnDate,
          columnType
        ],
        where: '$columnId = ?',
        whereArgs: <Object?>[id]));
    if (list.isNotEmpty) {
      return DbEvent()..fromMap(list.first);
    }
    return null;
  }

//CREATE TABLES
  Future _createDb(Database db) async {
    await db.execute('DROP TABLE If EXISTS $tableEvents');
    await db.execute(
        'CREATE TABLE $tableEvents($columnId INTEGER PRIMARY KEY, $columnFirstName TEXT, $columnLastName TEXT, $columnIdeas TEXT, $columnUpdated INTEGER, $columnDate INTEGER, $columnType TEXT)');
    await db
        .execute('CREATE INDEX EventsUpdated ON $tableEvents ($columnUpdated)');
    await _createNamedayTable(db);
    //SAMPLE DATA
    await _saveEvent(
        db,
        DbEvent()
          ..firstName.v = 'Inese'
          ..lastName.v = 'Bērziņa'
          ..ideas.v = 'grāmata par ceļojumiem'
          ..date.v = 1
          ..specialday.v = '2023-05-07'
          ..type.v = 'nameday');
    await _saveEvent(
        db,
        DbEvent()
          ..firstName.v = 'Sintija'
          ..lastName.v = 'Liepiņa'
          ..ideas.v = 'biļetes uz koncertu'
          ..date.v = 2
          ..specialday.v = '2023-05-09'
          ..type.v = 'birthday');
    _triggerUpdate();
  }

  Future open() async {
    await openPath(await fixPath(dbName));
  }

  Future<String> fixPath(String path) async => path;

  /// ADD or UPDATE CELEBRATION
  Future _saveEvent(DatabaseExecutor? db, DbEvent updatedEvent) async {
    if (updatedEvent.id.v != null) {
      await db!.update(tableEvents, updatedEvent.toMap(),
          where: '$columnId = ?', whereArgs: <Object?>[updatedEvent.id.v]);
    } else {
      updatedEvent.id.v = await db!.insert(tableEvents, updatedEvent.toMap());
    }
  }

  Future saveEvent(DbEvent updatedEvent) async {
    await _saveEvent(db, updatedEvent);
    _triggerUpdate();
  }

  Future<void> deleteEvent(int? id) async {
    await db!
        .delete(tableEvents, where: '$columnId = ?', whereArgs: <Object?>[id]);
    _triggerUpdate();
  }

  var eventsTransformer =
      StreamTransformer<List<Map<String, Object?>>, List<DbEvent>>.fromHandlers(
          handleData: (snapshotList, sink) {
    sink.add(DbEvents(snapshotList));
  });

  var eventTransformer =
      StreamTransformer<Map<String, Object?>, DbEvent?>.fromHandlers(
          handleData: (snapshot, sink) {
    sink.add(snapshotToEvent(snapshot));
  });

  /// Listen for changes on any event
  Stream<List<DbEvent?>> onEvents() {
    late StreamController<DbEvents> ctlr;
    StreamSubscription? triggerSubscription;

    Future<void> sendUpdate() async {
      var events = await getListEvents();
      if (!ctlr.isClosed) {
        ctlr.add(events);
      }
    }

    ctlr = StreamController<DbEvents>(onListen: () {
      sendUpdate();

      /// Listen for trigger
      triggerSubscription = _updateTriggerController.stream.listen((_) {
        sendUpdate();
      });
    }, onCancel: () {
      triggerSubscription?.cancel();
    });
    return ctlr.stream;
  }

  /// Listed for changes on a given event
  Stream<DbEvent?> onEvent(int? id) {
    late StreamController<DbEvent?> ctlr;
    StreamSubscription? triggerSubscription;

    Future<void> sendUpdate() async {
      var event = await getEvent(id);
      if (!ctlr.isClosed) {
        ctlr.add(event);
      }
    }

    ctlr = StreamController<DbEvent?>(onListen: () {
      sendUpdate();

      /// Listen for trigger
      triggerSubscription = _updateTriggerController.stream.listen((_) {
        sendUpdate();
      });
    }, onCancel: () {
      triggerSubscription?.cancel();
    });
    return ctlr.stream;
  }

  /// GET ALL SAVED CELEBRATIONS
  Future<DbEvents> getListEvents(
      {int? offset, int? limit, bool? descending}) async {
    // devPrint('fetching $offset $limit');
    var list = (await db!.query(tableEvents,
        columns: [columnId, columnFirstName, columnLastName, columnIdeas, columnDate, columnType],
        orderBy: '$columnDate ${(descending ?? true) ? 'ASC' : 'DESC'}',
        limit: limit,
        offset: offset));
    return DbEvents(list);
  }
 
Future<List<DbEvent>> getEventsForDay(DateTime selectedDate) async {
  final startOfSelectedDay =
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  final endOfSelectedDay = startOfSelectedDay.add(Duration(days: 1));

  final results = await db!.query(
    tableEvents,
    where: '$columnDate >= ? AND $columnDate < ?',
    whereArgs: [
      startOfSelectedDay.millisecondsSinceEpoch,
      endOfSelectedDay.millisecondsSinceEpoch
    ],
  );

  return results.map((snapshot) => snapshotToEvent(snapshot)).toList();
}


  Future clearAllEvents() async {
    await db!.delete(tableEvents);
    _triggerUpdate();
  }

  Future close() async {
    await db!.close();
  }

  Future deleteDb() async {
    await dbFactory.deleteDatabase(await fixPath(dbName));
  }


//parse CSV and write to table
  Future<void> _createNamedayTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableNameday');
    await db.execute(
        'CREATE TABLE $tableNameday($colId INTEGER PRIMARY KEY, $colDate TEXT, $colName TEXT)');
    var csvString = await rootBundle.loadString('assets/varda_dienas.csv');
    // print("namedays csv string: $csvString");
    // Clean up nameday csv - remove any quotes and empty space
    csvString = csvString.replaceAll(RegExp('"'), '');
    csvString = csvString.replaceAll(RegExp(' '), '');

    final lines = csvString.split('\n');
    final namedays = <Nameday>[];
    for (final line in lines) {
      final fields = line.split(',');
      if (fields.length == 2) {
        final date = fields[0];
        final name = fields[1];
        namedays.add(Nameday(date: date, name: name));
      } else {
        // If there are more than 1 nameday for the date, we have to add them all
        for (final field in fields) {
          if (field != fields[0]) {
            namedays.add(Nameday(date: fields[0], name: field));
          }
        }
      }
    }

    for (final nameday in namedays) {
      final insertedId = await db.rawInsert(
          'INSERT INTO $tableNameday($colDate, $colName) VALUES (?, ?)',
          [nameday.date, nameday.name]);
      //print("inserted value ${nameday.date}, ${nameday.name} into nameday database, id = $insertedId");
    }
    print("inserted ${namedays.length} lines into nameday database");
  }

//GET nameday for date selected
Future<String?> getNameday(String date) async {
  var result = await db?.query(tableNameday,
      columns: [colName],
      where: '$colDate = ?',
      whereArgs: [date]);

  if (result != null && result.isNotEmpty) {
    final List<String> resultList = [];
    for (final line in result) {
      resultList.add(line[colName] as String);
    }

    return resultList.join(', ');
    //return result.first[colName] as String?;
  } else {
    return null;
  }
}


  

  
}
