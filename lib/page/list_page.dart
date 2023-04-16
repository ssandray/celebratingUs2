// ignore_for_file: prefer_const_constructors, directives_ordering

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import '../main.dart';
import '../model/model.dart';
import '../page/edit_page.dart';
import './note_page.dart';

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
      body: StreamBuilder<List<DbNote?>>(
        stream: noteProvider.onNotes(),
        builder: (context, snapshot) {
          var notes = snapshot.data;
          if (notes == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                var note = notes[index]!;

                //LIST ITEM STYLE 

                return ListTile(
                  leading: Icon(Icons.cake),
                  title: Text(note.title.v ?? ''),
                  subtitle: Text(DateFormat('dd-MMM-yyy').format(DateTime.fromMillisecondsSinceEpoch(note.specialday.v ?? 0))),
                  // note.content.v?.isNotEmpty ?? false
                  //     ? Text(LineSplitter.split(note.content.v!).first)
                  //     : null , 
                  isThreeLine: true, 
                  trailing: Icon(Icons.more_vert),  
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return NotePage( //CHANGE THIS TO EDITPAGE
                        noteId: note.id.v,
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
