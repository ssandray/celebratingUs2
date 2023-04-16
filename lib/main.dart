// ignore_for_file: directives_ordering, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import 'calendar/calendar.dart';
import './page/edit_page.dart';
import './page/list_page.dart';
import './provider/note_provider.dart';

late DbNoteProvider noteProvider;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  platformInit();
  // For dev on windows, find the proper sqlite3.dll
  if (!kIsWeb) {
    sqfliteFfiInit();
  }
  var packageName = 'com.tekartik.sqflite.notepad';

  var databaseFactory = getDatabaseFactory(packageName: packageName);

  noteProvider = DbNoteProvider(databaseFactory);
  // devPrint('/notepad Starting');
  await noteProvider.ready;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celebrating Us',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(
        title: 'Celebrating Us',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//CHANGING PAGES
  int _currentIndex = 0;

  final List<Widget> _children = [
    TableEvents(), //calendar view
    NoteListPage(),
    Placeholder(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
          //POGAS AUGŠĀ
          actions: <Widget>[
            IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
          ],
        ),
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: onTabTapped,
            items: [
              (BottomNavigationBarItem(
                  label: 'Calendar', icon: Icon(Icons.calendar_month))),
              (BottomNavigationBarItem(label: 'List', icon: Icon(Icons.star))),
            ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {_showPopupDialog(context);}
        )
        );
  }
void _showPopupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Celebration', textAlign: TextAlign.center),
          backgroundColor: Theme.of(context).primaryColor,
          content: Container(
            height: 200,
            child: Column(
              children: [
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.pink), ),
                  onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return EditNotePage(
              initialNote: null,
            );
          })).then((value) => Navigator.pop(context));
                  },
                  child: Row(
                    children: [
                      Icon(Icons.coffee), 
                      SizedBox(width: 8),
                      Text('Name day'),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Implement logic for  button
                  },
                  child: Row(
                    children: [
                      Icon(Icons.cake), 
                      SizedBox(width: 8),
                      Text('Birthday'),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green), ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Implement logic for  button
                  },
                  child: Row(
                    children: [
                      Icon(Icons.celebration), 
                      SizedBox(width: 8),
                      Text('Anniversary'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
  

