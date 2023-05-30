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
                    //alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 5, top: 3, bottom: 3),
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: Color.fromARGB(255, 206, 206, 206)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            // alignment: Alignment.center,
                            padding: EdgeInsets.all(1),
                            margin: EdgeInsets.symmetric(
                                horizontal: 1, vertical: 1),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Colors.orange),
                            height: 66,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                  DateFormat('yyyy').format(DateTime.parse(
                                      event.evdate.v ?? '1970-01-01')),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: ShapeDecoration(
                                        color: getColorBasedOnEventType(
                                            event.type.v ?? ''),
                                        shape: CircleBorder(),
                                      ),
                                    ),
                                    Text(
                                      ' #' + (event.type.v ?? ''),
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
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
                                //Text('text'),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            //  crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 15,
                              ),
                              SizedBox(height: 30),
                              //Text('Item 5'),
                              //Text('Item 6'),
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

  Color getColorBasedOnEventType(String eventType) {
    if (eventType == 'nameday') {
      return Colors.pink;
    } else if (eventType == 'birthday') {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }
}
