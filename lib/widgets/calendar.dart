// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

//import './utils.dart';
import '../widgets/list.dart';
import '../db/events_provider.dart';
import '../model/nameday_constant.dart';
import '../model/model.dart';
import '../model/model_constant.dart';
import '../db/db.dart';
import '../main.dart';

class TableEvents extends StatefulWidget {
   final DbEventsProvider eventsProvider;
   
   const TableEvents({Key? key, required this.eventsProvider}) : super(key: key);

   
  @override
  _TableEventsState createState() => _TableEventsState(eventsProvider);
}

class _TableEventsState extends State<TableEvents> {
  late final DbEventsProvider eventsProvider;
  late final Database db;
  //late final ValueNotifier<List<Event>> _selectedEvents;
  // late final ValueNotifier<List<DbEvent>> _selectedEvents;
   late final ValueNotifier<List<DbEvent>> _selectedEvents = ValueNotifier([]);
  CalendarFormat _calendarFormat = CalendarFormat.month;   //DEFAULT CALENDAR VIEW
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _namedaysText;
  //
 

 _TableEventsState(this.eventsProvider) {
    db = eventsProvider.db!;
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
// List<Event> _getEventsForDay(DateTime day) { 
//     // Implementation example - LIST OF SAVED EVENTS
//     return kEvents[day] ?? []; //nomainīt
//   }

 Future<List<DbEvent>> _getEventsForDay(DateTime dateTime) async {
  List<DbEvent> list= await eventsProvider.getEventsForDay(dateTime);
 // print('namedays loaded:' + list!); ar for
  //final list = await eventsProvider.getEventsForDay(dateTime);
  return list;
}


//GET NAMEDAYS FOR DAY SELECTED
  Future<String?> getNameday(DateTime datetime) async {
    final formattedDate = DateFormat('dd.MM.').format(datetime);
    final result = await eventsProvider.getNameday(formattedDate);

    print('namedays loaded:' + result!);
    return result;
  }

  //GET NAMEDAYS and EVENTS for selected
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

      // perform any desired operations with the retrieved data (e.g. display in UI)
      print('Selected day: $selectedDay, Nameday: $nameDays, Events: $events');
    } else {
      print('Selected day is same as before!');
    }
  }

  Map<CalendarFormat, String> availableCalendarFormats = {         //define calendar views
    CalendarFormat.month: 'Week',
    CalendarFormat.week: 'Month',
  };

  

  @override
  Widget build(BuildContext context) {
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 10, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 10, kToday.day);
    return Container(
        child: Column(
          children: [
            TableCalendar<DbEvent>(
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

            //LIST FOR DATE SELECTED
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

            //Celebrations for selected
            Container(child: Text('Celebrations'),alignment: Alignment.centerLeft, padding: EdgeInsets.only(left: 20, top: 20)), 
            Container(
              height: 211,
              child: NoteListPage()),        
            
            //EVENT LIST FOR SELECTED

            Expanded(
              child: 
              ValueListenableBuilder<List<DbEvent>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0, 
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          onTap: () => print('${value[index]}'),
                          title: Text('${value[index]}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
          ],
        ),
    );
  }
  
}
