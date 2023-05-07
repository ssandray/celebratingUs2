// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../main.dart';
import '../model/model.dart';
import 'edit_event.dart';

class EventDetailsPage extends StatefulWidget {
  final int? eventId;

  const EventDetailsPage({Key? key, required this.eventId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<EventDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DbEvent?>(
      stream: eventsProvider.onEvent(widget.eventId),
      builder: (context, snapshot) {
        var event = snapshot.data;

        void edit() {
          if (event != null) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return EditEventPage(
                initialEvent: event,
              );
            }));
          }
        }

        return Scaffold(
            appBar: AppBar(
              title: Text(
                'Celebration',
              ),
              actions: <Widget>[
                if (event != null)
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      edit();
                    },
                  ),
              ],
            ),
            body: (event == null)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : GestureDetector(
                    onTap: () {
                      edit();
                    },
                    child: ListView(children: <Widget>[
                      ListTile(
                          title: Text(
                        event.title.v!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      ListTile(title: Text(event.ideas.v ?? ''))
                    ]),
                  ));
      },
    );
  }
}
