// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

//import './utils.dart';
import '../page/list_page.dart';
import '../provider/note_provider.dart';
import '../model/nameday_constant.dart';
import '../model/model.dart';
import '../model/model_constant.dart';
import '../db/db.dart';
import '../main.dart';

class TableEvents extends StatefulWidget {
   final DbNoteProvider noteProvider;
   
   const TableEvents({Key? key, required this.noteProvider}) : super(key: key);

   
  @override
  _TableEventsState createState() => _TableEventsState(noteProvider);
}

class _TableEventsState extends State<TableEvents> {
  late final DbNoteProvider noteProvider;
  late final Database db;
  //late final ValueNotifier<List<Event>> _selectedEvents;
  // late final ValueNotifier<List<DbNote>> _selectedEvents;
  late final ValueNotifier<List<DbNote>> _selectedEvents = ValueNotifier([]);
  CalendarFormat _calendarFormat = CalendarFormat.month;   //DEFAULT CALENDAR VIEW
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _namedaysText;
  //
 

 _TableEventsState(this.noteProvider) {
    db = noteProvider.db!;
    _selectedDay = _focusedDay;
   // _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _namedaysText = '';

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

  //GET EVENTS FOR DAY SELECTED
  Future<List<DbNote>> _getEventsForDay(DateTime dateTime) async {
    List<DbNote> list = await noteProvider.getEventsForDay(dateTime);
    return list;
  }

  //GET NAMEDAYS FOR DAY SELECTED
  Future<String?> getNameday(DateTime datetime) async {
    final formattedDate = DateFormat('dd.MM.').format(datetime);
    final result = await noteProvider.getNameday(formattedDate);

    print('namedays loaded:' + result!);
    return result;
  }

  //UPDATE NAMEDAYS and EVENTS for selected
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    _updateSelectedDay(selectedDay, focusedDay, false);
  }

  void _updateSelectedDay(DateTime selectedDay, DateTime focusedDay, bool forceUpdate) async {
    if (!isSameDay(_selectedDay, selectedDay) || forceUpdate) {
      final nameDays = await getNameday(selectedDay); // get nameday from database
      final events = await _getEventsForDay(selectedDay); // get events for selected day

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
    final kFirstDay = DateTime(kToday.year, kToday.month - 10, kToday.day);
    final kLastDay = DateTime(kToday.year, kToday.month + 10, kToday.day);

    return Column(
      children: [
        TableCalendar<DbNote>(
          calendarBuilders: CalendarBuilders(), //customize icons for events
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          availableCalendarFormats: availableCalendarFormats,
          calendarFormat: _calendarFormat,
          //eventLoader: _getEventsForDay,                          //HOW TO FIX THIS ERROR
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: const CalendarStyle(// Use `CalendarStyle` to customize the UI
              outsideDaysVisible: false,
              tableBorder: TableBorder(bottom: BorderSide(color: Colors.orange, style: BorderStyle.solid)),
              tablePadding: EdgeInsets.only(bottom: 10)
          ),
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

        const SizedBox(height: 8.0),
        Container(alignment: Alignment.centerLeft, padding: EdgeInsets.only(left: 20),
            child: Text(DateFormat('EEEE, dd MMM, yyyy').format(_selectedDay!))),

        //Namedays for selected
        Container(alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0), color: Colors.orange
          ),
          child: Text(_namedaysText.toString()),
        ),

        //Celebrations for selected date
        Flexible(
          child:
          ValueListenableBuilder<List<DbNote>>(
            valueListenable: _selectedEvents,
            builder: (context, items, _) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final note = items[index]!;
                  return Container(
                    child: ListTile(
                      leading: const Icon(Icons.cake),
                      title: Text(note.title.v ?? ''),
                      subtitle: Text(DateFormat('dd-MMM-yyy').format(DateTime.fromMillisecondsSinceEpoch(note.specialday.v ?? 0))),
                      trailing: const Icon(Icons.more_vert),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Text('Upcoming celebrations')
        ),
        Flexible(
            child: NoteListPage()),
      ],
    );
  }
  
}
