// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import '../main.dart';
import '../model/model.dart';

class EditEventPage extends StatefulWidget {
  /// null when adding a note
  final DbEvent? initialEvent;

  const EditEventPage({Key? key, required this.initialEvent}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _titleTextController;
  TextEditingController? _ideasTextController;
  TextEditingController? _specialdayTextController;

  int? get _eventId => widget.initialEvent?.id.v;
  @override
  void initState() {
    super.initState();
    _titleTextController =
        TextEditingController(text: widget.initialEvent?.title.v);
    _ideasTextController =
        TextEditingController(text: widget.initialEvent?.ideas.v);
    _specialdayTextController = TextEditingController(
          text: widget.initialEvent?.specialday.v != null
              ? DateFormat('yyyy-MM-dd').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      widget.initialEvent!.specialday.v!))
              : null);  
  }

  Future save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print("Selected date before saving: ${_specialdayTextController!.text}");
      // Convert the string representation of date to epoch timestamp
    String dateString = _specialdayTextController!.text;
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parseStrict(dateString);
    int epochTimestamp = parsedDate.millisecondsSinceEpoch;
    print("Parsed value: $epochTimestamp");
      await eventsProvider.saveEvent(DbEvent()
        ..id.v = _eventId
        ..title.v = _titleTextController!.text
        ..ideas.v = _ideasTextController!.text
        ..date.v = DateTime.now().millisecondsSinceEpoch
        ..specialday.v = epochTimestamp); 
        
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // Pop twice when editing
      if (_eventId != null) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var dirty = false;
        if (_titleTextController!.text != widget.initialEvent?.title.v) {
          dirty = true;
        } else if (_ideasTextController!.text !=
            widget.initialEvent?.ideas.v) {
          dirty = true;
        }
        if (dirty) {
          return await (showDialog<bool>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Leave before saving?'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text(''),
                            SizedBox(
                              height: 12,
                            ),
                            Text('Tap \'BACK\' to discard'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text('BACK'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text('CANCEL'),
                        ),
                      ],
                    );
                  })) ??
              false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Add celebration',
          ),
          actions: <Widget>[
            if (_eventId != null)
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  // ignore: use_build_context_synchronously
                  if (await showDialog<bool>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete celebration?'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text(
                                        'Tap \'YES\' to confirm'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text('YES'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('NO'),
                                ),
                              ],
                            );
                          }) ??
                      false) {
                    await eventsProvider.deleteEvent(widget.initialEvent!.id.v);
                    // Pop twice to go back to the list
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                },
              ),
            // action button
            TextButton(
          onPressed: () {
                 save();
               },
          child: Text(
            'Done',
            style: TextStyle(fontSize: 18.0),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black, 
              ))
            // IconButton(
            //   icon: Icon(Icons.star),
            //   onPressed: () {
            //     save();
            //   },
            // ),
          ],
        ),

        // ADDING NEW

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(children: <Widget>[
            Form(
                key: _formKey,
                child: Container( 
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        //NAME
                        Text('Name'),
                        Padding(padding: EdgeInsets.all(1)),
                        TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300],
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,), 
                            ),
                          controller: _titleTextController,
                          validator: (val) =>
                              val!.isNotEmpty ? null : 'Please enter name',
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        //DATE
                        Text('Date'),
                        Padding(padding: EdgeInsets.all(1)),
                        TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300],
                            labelText: 'pick a date',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none, 
                            ),
                          ),
                          controller: _specialdayTextController,
                          onTap: () async {
                            var pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(
                                    2023), //DateTime.now() - not to allow to choose before today.
                                lastDate: DateTime(2033));
                
                            if (pickedDate != null) {
                              print(
                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                              print(
                                  formattedDate); //formatted date output using intl package =>  2021-03-16
                              //you can implement different kind of Date Format here according to your requirement
                
                              setState(() {
                                _specialdayTextController!.text =
                                    formattedDate; //set output date to TextField value.
                              });
                            } else {
                              print('Please pick a date');
                            }
                          },
                          validator: (val) =>
                               val!.isNotEmpty ? null : 'Please pick a date',
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        //IDEAS
                        Text('Notes and gift ideas'),
                        Padding(padding: EdgeInsets.all(1)),
                        TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300],
                            labelText: 'Add notes',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none, 
                            ),
                          ),
                          controller: _ideasTextController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                        )
                      ]),
                ))
          ]),
        ),
      ),
    );
  }
}
