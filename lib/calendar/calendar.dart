// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import './utils.dart';
import '../page/list_page.dart';

class TableEvents extends StatefulWidget {
  @override
  _TableEventsState createState() => _TableEventsState();
}

class _TableEventsState extends State<TableEvents> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;   //week, 2week, month
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }


  List<Event> _getEventsForDay(DateTime day) {
    
    // Implementation example - LIST OF SAVED EVENTS
    return kEvents[day] ?? [];
  }


  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }
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
            Container(child: Text('Thursday, 30 March, 2023'),alignment: Alignment.centerLeft, padding: EdgeInsets.only(left: 20)),
            Container(child: Text('Nanija, Ilgmārs'),alignment: Alignment.centerLeft, 
            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10), 
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0), color: Colors.orange
                        ),
                        ),
            Container(child: Text('Celebrations'),alignment: Alignment.centerLeft, padding: EdgeInsets.only(left: 20, top: 20)), 
            Container(
              height: 211,
              child: NoteListPage()),        
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
