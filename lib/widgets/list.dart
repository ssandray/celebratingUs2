// ignore_for_file: prefer_const_constructors, directives_ordering

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import '../main.dart';
import '../model/model.dart';
import '../pages/edit_event.dart';
import '../pages/event_details.dart';
import '../utils/repeated_events.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          return ListView.builder(
              itemCount: EventUtils.repeatedEvents.length,
              itemBuilder: (context, index) {
                var event = EventUtils.repeatedEvents[index];

                //LIST ITEM STYLE

                // return ListTile(
                //   leading: Icon(Icons.cake),
                //   title: Text((event.firstName.v ?? '') + ' ' + (event.lastName.v ?? '')),
                //    visualDensity:VisualDensity(horizontal: 0, vertical: -4),
                //   subtitle: Text(DateFormat('yyyy-MM-dd').format(
                //       DateTime.parse(event.evdate.v ?? '1970-01-01'))),
                //   isThreeLine: true,
                //   trailing: Icon(Icons.more_vert),
                //   onTap: () {
                //     int originalEventId = 0;
                //     String eventIdString = event.id.v?.toString() ?? '';
                //     if (eventIdString.isNotEmpty) {
                //       String truncatedId =
                //           eventIdString.substring(0, eventIdString.length - 1);
                //       int? parsedId = int.tryParse(truncatedId);
                //       if (parsedId != null) {
                //         originalEventId = parsedId;
                //       }
                //     }
                //     Navigator.of(context)
                //         .push(MaterialPageRoute(builder: (context) {
                //       return EventDetailsPage(
                //         eventId: originalEventId,
                //       );
                //     }));
                //   },
                // )
                ;
                return GestureDetector(
                  onTap: () {
                    int originalEventId = 0;
                    String eventIdString = event.id.v?.toString() ?? '';
                    if (eventIdString.isNotEmpty) {
                      String truncatedId =
                          eventIdString.substring(0, eventIdString.length - 1);
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
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        

                        Expanded(
                          flex: 1,
                          child: Container(
                            color: Colors.orange,
                           // width: 50,
                            height: 50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat('dd').format(DateTime.parse(
                                    event.evdate.v ?? '1970-01-01'))),
                                Text(DateFormat('MMM').format(DateTime.parse(
                                    event.evdate.v ?? '1970-01-01'))),
                                Text(DateFormat('yyyy').format(DateTime.parse(
                                    event.evdate.v ?? '1970-01-01'))),
                              ],
                            ),
                          ),
                        ),
                        


                        Expanded(
                          flex: 4, 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((event.firstName.v ?? '') +
                                  ' ' +
                                  (event.lastName.v ?? '')),
                              Text('Item 4'),
                            ],
                          ),
                        ),




                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Item 5'),
                              Text('Item 6'),
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
    );
  }
}
