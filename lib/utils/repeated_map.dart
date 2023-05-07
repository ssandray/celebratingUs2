import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';
import '../model/model.dart';

import '../model/model_constant.dart';
export './repeated_map.dart';

// Function to get all events from the database
Future<List<DbEvent>> getAllEvents(Database db) async {
  final result = await db.query(tableEvents);
  return result.map((e) => DbEvent()..fromMap(e)).toList();
}

// Function to repeat event for the next 10 years
List<DbEvent> repeatEvent(DbEvent event) {
  final List<DbEvent> events = [];

  final date = DateTime.parse(event.specialday.v!);
  final formatter = DateFormat('yyyy-MM-dd');

  for (int i = 1; i <= 10; i++) {
    final newDate = date.add(Duration(days: 365 * i));
    final newEvent = DbEvent()
      ..title.v = event.title.v
      ..ideas.v = event.ideas.v
      ..date.v = event.date.v
      ..specialday.v = formatter.format(newDate)
      ..type.v = event.type.v;
    events.add(newEvent);
  }

  return events;
}

// Function to get a LinkedHashMap of all events repeated for the next 10 years
Future<LinkedHashMap<String, List<DbEvent>>> getAllEventsRepeated(
    Database db) async {
  final List<DbEvent> events = await getAllEvents(db);

  final LinkedHashMap<String, List<DbEvent>> map = LinkedHashMap();

  for (final event in events) {
    final repeatedEvents = repeatEvent(event);
    for (final repeatedEvent in repeatedEvents) {
      final key = repeatedEvent.specialday.v!;
      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]!.add(repeatedEvent);
    }
  }

  return map;
}
