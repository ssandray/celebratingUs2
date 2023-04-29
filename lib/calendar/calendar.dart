// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

import './utils.dart';
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
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;   //DEFAULT CALENDAR VIEW
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  //
 

 _TableEventsState(this.noteProvider) {
    db = noteProvider.db!;
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void initState() {
    super.initState();
    db.init(); // initialize the database object
  }


  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }
  //



  // @override
  // void initState() {
  //   super.initState();

  //   _selectedDay = _focusedDay;
  //   _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  // }

  // @override
  // void dispose() {
  //   _selectedEvents.dispose();
  //   super.dispose();
  // }

//GET EVENTS FOR DAY SELECTED
  List<Event> _getEventsForDay(DateTime day) {
    
    // Implementation example - LIST OF SAVED EVENTS
    return kEvents[day] ?? []; //nomainīt
  }

//GET NAMEDAY
Future<String?> getNameday(String date) async {
  DateTime selectedDay = DateFormat('dd.MM.').parse(date); // format date string
  String formattedDate = DateFormat('dd.MM.').format(selectedDay); 

  var query = await db.query(tableNameday,
      columns: [colName],
      where: '$colDate = ?',
      whereArgs: [formattedDate]) as List<Map<String, dynamic>>;

  if (query.isNotEmpty) {
    return query.first[colName] as String?;
  } else {
    return null;
  }
}
  //GET NAMEDAYS and EVENTS for selected
void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
  if (!isSameDay(_selectedDay, selectedDay)) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

  
   String formattedDate = DateFormat('dd.MM.').format(selectedDay);
    final nameDay = await getNameday(formattedDate); // get nameday from database
    final events = _getEventsForDay(selectedDay); // get events for selected day
    
    // perform any desired operations with the retrieved data (e.g. display in UI)
    print('Selected day: $selectedDay, Nameday: $nameDay, Events: $events');
  }
}


  // void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
  //   if (!isSameDay(_selectedDay, selectedDay)) {
  //     setState(() {
  //       _selectedDay = selectedDay;
  //       _focusedDay = focusedDay;
  //     });

  //     _selectedEvents.value = _getEventsForDay(selectedDay);
  //   }
  // }


Map<CalendarFormat, String> availableCalendarFormats = {         //define calendar views
  CalendarFormat.month: 'Week',
  CalendarFormat.week: 'Month',
};

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: [
            TableCalendar<Event>(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              availableCalendarFormats: availableCalendarFormats,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(                // Use `CalendarStyle` to customize the UI
                
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

            //LIST FOR DATE SELECTED
            const SizedBox(height: 8.0),
            Container(alignment: Alignment.centerLeft, padding: EdgeInsets.only(left: 20), 
            child: Text(DateFormat('EEEE, dd.MM.yyyy').format(_selectedDay!))),
            Container(alignment: Alignment.centerLeft, 
            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10), 
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0), color: Colors.orange
                        ),
                        child: Text(getNameday.toString()),
                        ),
            Container(child: Text('Celebrations'),alignment: Alignment.centerLeft, padding: EdgeInsets.only(left: 20, top: 20)), 
            Container(
              height: 211,
              child: NoteListPage()),        
            
            //EVENT LIST FOR SELECTED

            // Expanded(
            //   child: 
            //   ValueListenableBuilder<List<Event>>(
            //     valueListenable: _selectedEvents,
            //     builder: (context, value, _) {
            //       return ListView.builder(
            //         itemCount: value.length,
            //         itemBuilder: (context, index) {
            //           return Container(
            //             margin: const EdgeInsets.symmetric(
            //               horizontal: 12.0, 
            //               vertical: 4.0,
            //             ),
            //             decoration: BoxDecoration(
            //               border: Border.all(),
            //               borderRadius: BorderRadius.circular(12.0),
            //             ),
            //             child: ListTile(
            //               onTap: () => print('${value[index]}'),
            //               title: Text('${value[index]}'),
            //             ),
            //           );
            //         },
            //       );
            //     },
            //   ),
            // ),
            
          ],
        ),
    );
  }
}
