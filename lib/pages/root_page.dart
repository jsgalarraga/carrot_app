import 'package:carrot_app/pages/maps_page.dart';
import 'package:carrot_app/pages/places_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Widget> _pages = <Widget>[
    MapsPage(),
    PlacesPage()
  ];

  void _onNavBarItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarItemTap,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: AppLocalizations.of(context)!.maps,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place_outlined),
            label: AppLocalizations.of(context)!.places,
          ),
        ],
      ),
    );
  }
}
