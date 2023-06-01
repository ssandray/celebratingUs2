// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

import '../widgets/list.dart';
import '../db/events_provider.dart';
import '../model/nameday_constant.dart';
import '../model/model.dart';
import '../model/model_constant.dart';
import '../db/db.dart';
import '../main.dart';
import '../utils/repeated_events.dart';
import '../pages/event_details.dart';

class TableEvents extends StatefulWidget {
  final DbEventsProvider eventsProvider;
  final events = EventUtils.repeatedEvents;

  TableEvents({Key? key, required this.eventsProvider}) : super(key: key);

  @override
  _TableEventsState createState() => _TableEventsState(eventsProvider);
}

class _TableEventsState extends State<TableEvents> {
  late final DbEventsProvider eventsProvider;
  late final Database db;
  late final ValueNotifier<List<DbEvent>> _selectedEvents = ValueNotifier([]);
  late Stream<List<DbEvent>> eventStream;
  Map<DateTime, List<DbEvent>> _eventsByDate = {};
  CalendarFormat _calendarFormat = CalendarFormat.month; //DEFAULT CALENDAR VIEW

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _namedaysText;

  _TableEventsState(this.eventsProvider) {
    db = eventsProvider.db!;
    _selectedDay = _focusedDay;
    _namedaysText = '';

    eventStream = eventsProvider.onEvents();
    eventStream.listen((events) {
      _updateEventsByDate(events);
    });

    _updateSelectedDay(_selectedDay!, _focusedDay, true);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void _updateEventsByDate(List<DbEvent> list) {
    final Map<DateTime, List<DbEvent>> newEventsByDate = {};
    for (final event in list) {
      final date = DateTime.parse(event.evdate.v!);
      if (newEventsByDate.containsKey(date)) {
        newEventsByDate[date]!.add(event);
      } else {
        newEventsByDate[date] = [event];
      }
    }

    print('events updated for ${newEventsByDate.keys.length} dates');

    setState(() {
      _eventsByDate = newEventsByDate;
    });
  }

  DateTime _getOnlyDatePart(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
  }

//GET EVENTS FOR DAY SELECTED
  List<DbEvent> _getEventsForDay(DateTime dateTime) {
    final events = _eventsByDate[_getOnlyDatePart(dateTime)];
    return events ?? <DbEvent>[];
  }

//GET NAMEDAYS FOR DAY SELECTED
  Future<String?> getNameday(DateTime datetime) async {
    final formattedDate = DateFormat('dd.MM.').format(datetime);
    final result = await eventsProvider.getNameday(formattedDate);

    print('namedays loaded:' + result!);
    return result;
  }

  //UPDATE NAMEDAYS and EVENTS for selected
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    _updateSelectedDay(selectedDay, focusedDay, false);
  }

  void _updateSelectedDay(
      DateTime selectedDay, DateTime focusedDay, bool forceUpdate) async {
    if (!isSameDay(_selectedDay, selectedDay) || forceUpdate) {
      final nameDays =
          await getNameday(selectedDay); // get nameday from database
      final events =
          _getEventsForDay(selectedDay); // get events for selected day

      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _namedaysText = nameDays;
      });

      _selectedEvents.value = events;

      // perform any desired operations with the retrieved data (e.g. display in UI)
      print('Selected day: $selectedDay, Nameday: $nameDays, Events: $events');
    } else {
      print('Selected day is same as before!');
    }
  }

//define calendar views
  Map<CalendarFormat, String> availableCalendarFormats = {
    CalendarFormat.month: 'Week',
    CalendarFormat.week: 'Month',
  };

  @override
  Widget build(BuildContext context) {
    final kToday = DateTime.now();
    final kFirstDay = DateTime(kToday.year - 1, kToday.month, kToday.day);
    final kLastDay = DateTime(kToday.year + 1, kToday.month, kToday.day);

    return Container(
      child: Column(
        children: [
          TableCalendar<DbEvent>(
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  final List<String> eventTypes =
                      events.map((event) => event.type.v!).toSet().toList();
                  final maxMarkers = 3; // Maximum number of markers to display

                  return Align(
                    alignment: Alignment(0, 0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: eventTypes.take(maxMarkers).map((eventType) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(getMarkerIcon(eventType),
                                color: getMarkerColor(eventType), size: 8),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ), //customize ICONS for events
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            availableCalendarFormats: availableCalendarFormats,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
                // Use `CalendarStyle` to customize the UI
                outsideDaysVisible: false,
                tableBorder: TableBorder(
                    bottom: BorderSide(
                        color: Colors.orange, style: BorderStyle.solid)),
                tablePadding: EdgeInsets.only(bottom: 10)),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),

          //LIST FOR DATE SELECTED
          const SizedBox(height: 8.0),
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20),
              child: Text(
                (DateFormat('EEEE, dd MMM, yyyy').format(_selectedDay!)),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              )),

          //Namedays for selected
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.orange),
            child: Text(
              _namedaysText.toString(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),

//Celebrations for selected date
          Container(
            child: ValueListenableBuilder<List<DbEvent>>(
              valueListenable: _selectedEvents,
              builder: (context, items, _) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final event = items[index];
                      return GestureDetector(
                        onTap: () {
                          int originalEventId = 0;
                          String eventIdString = event.id.v?.toString() ?? '';
                          if (eventIdString.isNotEmpty) {
                            String truncatedId = eventIdString.substring(
                                0, eventIdString.length - 1);
                            int? parsedId = int.tryParse(truncatedId);
                            if (parsedId != null) {
                              originalEventId = parsedId;
                            }
                          }
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return EventDetailsPage(
                              eventId: originalEventId,
                            );
                          }));
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 5, top: 3, bottom: 3),
                          margin:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              color: Color.fromARGB(200, 221, 221, 221)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.all(1),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 1),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0),
                                      color: Colors.orange),
                                  height: 66,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('dd').format(DateTime.parse(
                                            event.evdate.v ?? '1970-01-01')),
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        DateFormat('MMM').format(DateTime.parse(
                                            event.evdate.v ?? '1970-01-01')),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        DateFormat('yyyy').format(
                                            DateTime.parse(event.evdate.v ??
                                                '1970-01-01')),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: EdgeInsets.all(1),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 1),
                                  height: 66,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: ShapeDecoration(
                                              color: getMarkerColor(
                                                  event.type.v ?? ''),
                                              shape: CircleBorder(),
                                            ),
                                          ),
                                          Text(
                                            ' #' + (event.type.v ?? ''),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        (event.firstName.v ?? '') +
                                            ' ' +
                                            (event.lastName.v ?? ''),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 15,
                                    ),
                                    SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
          SizedBox(height: 20),
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Text('Upcoming celebrations',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          Flexible(child: ListPage()),
        ],
      ),
    );
  }

  IconData getMarkerIcon(String eventType) {
    switch (eventType) {
      case 'nameday':
        return Icons.circle;
      case 'birthday':
        return Icons.circle;
      case 'other':
        return Icons.circle;
      default:
        return Icons.circle;
    }
  }

  Color getMarkerColor(String eventType) {
    switch (eventType) {
      case 'nameday':
        return Colors.pink;
      case 'birthday':
        return Colors.blue;
      case 'other':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
