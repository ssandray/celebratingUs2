// ignore_for_file: prefer_const_constructors, directives_ordering

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import '../main.dart';
import '../model/model.dart';
import '../pages/edit_event.dart';
import '../pages/event_details.dart';
import '../utils/repeated_events.dart';


class NoteListPage extends StatefulWidget {
  const NoteListPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NoteListPageState createState() => _NoteListPageState();
}


class _NoteListPageState extends State<NoteListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     title: Text(
      //   'List',
      // )),

      //LOAD list of saved events
      body: StreamBuilder<List<DbEvent?>>(
        stream: eventsProvider.onEvents(),
        builder: (context, snapshot) {
          var events = snapshot.data;
          if (events == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
EventUtils.generateRepeatedEvents(events);
// //List to hold the repeated events
//       List<DbEvent> repeatedEvents = [];

//       // Iterate through each event and repeat it for the next 10 years
//       for (var event in events) {
//         // Get the special day for the current event
//         var specialDay = DateTime.parse(event?.specialday.v ?? '1970-01-01');

//         // Iterate through the next 10 years and repeat the event
//       for (int i = 0; i < 10; i++) {
//           // Add the repeated event to the list
//           repeatedEvents.add(DbEvent()
//             ..id.v = int.parse('${event?.id.v}$i')
//             ..title.v = event?.title.v
//             ..specialday.v =  DateTime(specialDay.year + i, specialDay.month, specialDay.day).toString()
//             ..ideas.v = event?.ideas.v
//           );
//         }
//       }

//       // Sort the list of repeated events by the special day
//     repeatedEvents.sort((a, b) => DateTime.parse(a.specialday.v!).compareTo(DateTime.parse(b.specialday.v!)));




          return ListView.builder(
              itemCount: EventUtils.repeatedEvents.length, //repeatedEvents.length,
              itemBuilder: (context, index) {
                var event = EventUtils.repeatedEvents[index];
                
                //LIST ITEM STYLE 

                return ListTile(
                  leading: Icon(Icons.cake),
                  title: Text(event.title.v ?? ''),
                  //subtitle: Text(DateFormat('dd-MMM-yyy').format(DateTime.fromMillisecondsSinceEpoch(event.specialday.v ?? 0))),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(event.specialday.v ?? '1970-01-01'))),
                  // event.ideas.v?.isNotEmpty ?? false
                  //     ? Text(LineSplitter.split(event.ideas.v!).first)
                  //     : null , 
                  isThreeLine: true, 
                  trailing: Icon(Icons.more_vert),  
                  // onTap: () {
                  //   Navigator.of(context)
                  //       .push(MaterialPageRoute(builder: (context) {
                  //     return EventDetailsPage( 
                  //       eventId: repeatedEvents[index].id.v,
                  //     );
                  //   }));
                  // },
    onTap: () {
  int originalEventId = int.parse(event.id.v.toString().substring(0, event.id.v.toString().length - 1));
  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    return EventDetailsPage(
      eventId: originalEventId,
    );
  }));
},

                );
              });
        },
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      //       return EditNotePage(
      //         initialNote: null,
      //       );
      //     }));
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
