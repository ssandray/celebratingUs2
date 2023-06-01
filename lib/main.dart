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
    DeviceOrientation.portraitUp, //LOCK to PORTRAIT MODE
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
        title: 'Calendar', //HEADER TITLE
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//CHANGING PAGES
  int _currentIndex = 0;

  final List<Widget> _children = [
    TableEvents(eventsProvider: eventsProvider), //calendar view
    ListPage(),
    Placeholder(),
  ];

List<String> _tabLabels = ['Calendar', 'List of celebrations'];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      widget.title = _tabLabels[_currentIndex];
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
                icon: Icon(Icons.settings_outlined)),
          ],
        ),
        body: _children[_currentIndex],
        bottomNavigationBar: Container(
          height: 68,
          child: Container(
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              iconSize: 30,
              backgroundColor: Colors.black,
              selectedItemColor: Colors.orange, // Color when item is selected
              unselectedItemColor:
                  Colors.white, // Color when item is not selected
              showUnselectedLabels: true,
              unselectedLabelStyle:
                  TextStyle(color: Colors.white), // Unselected label color
              selectedLabelStyle:
                  TextStyle(color: Colors.orange), // Selected label color
              currentIndex: _currentIndex,
              onTap: onTabTapped,
              items: const [
                (BottomNavigationBarItem(
                    label: 'Calendar', icon: Icon(Icons.calendar_month_rounded))),
                (BottomNavigationBarItem(
                    label: 'List', icon: Icon(Icons.star_border))),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          width: 72,
          height: 72,
          child: FloatingActionButton(
              child: Icon(Icons.add, size: 45),
              onPressed: () {
                _showPopupDialog(context);
              }),
        ));
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
                        typeTitle: 'New Name Day',
                        backgroundColor: Colors.pink,
                        type: 'nameday',
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
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditEventPage(
                        initialEvent: null,
                        typeTitle: 'New Birthday',
                        backgroundColor: Colors.blue,
                        type: 'birthday',
                      );
                    })).then((value) => Navigator.pop(context));
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
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditEventPage(
                          initialEvent: null,
                          typeTitle: 'New Celebration',
                          backgroundColor: Colors.green,
                          type: 'other');
                    })).then((value) => Navigator.pop(context));
                  },
                  child: Row(
                    children: [
                      Icon(Icons.celebration),
                      SizedBox(width: 8),
                      Text('Custom celebration'),
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

  final List<String> bottomNavigationBarLabels = [
  'Calendar',
  'List',
];
String getSelectedLabel() {
  return bottomNavigationBarLabels[_currentIndex];
}
}
