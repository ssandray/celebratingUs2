// ignore_for_file: directives_ordering, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import 'widgets/calendar.dart';
import 'pages/edit_event.dart';
import 'widgets/list.dart';
import 'db/events_provider.dart';
import 'pages/settings.dart';
import 'package:flutter/services.dart';

late DbEventsProvider eventsProvider;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  platformInit();
  // For dev on windows, find the proper sqlite3.dll
  if (!kIsWeb) {
    sqfliteFfiInit();
  }
  var packageName = 'com.tekartik.sqflite.notepad';

  var databaseFactory = getDatabaseFactory(packageName: packageName);

  eventsProvider = DbEventsProvider(databaseFactory);
  // devPrint('/notepad Starting');
  await eventsProvider.ready;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,      //LOCK to PORTRAIT MODE
    DeviceOrientation.portraitDown,
  ]);
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
        title: 'Celebrating Us', //HEADER TITLE
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
    TableEvents(eventsProvider: eventsProvider), //calendar view
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
          //HEADER BUTTONS
          actions: <Widget>[
            IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                  // This code will be executed when the settings screen is popped
                  // Refresh the screen to reflect any changes made in the settings
                  setState(() {});
                },
                icon: Icon(Icons.settings)),
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
            onPressed: () {
              _showPopupDialog(context);
            }));
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
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.pink),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditEventPage(
                        initialEvent: null,
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
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
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
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
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
