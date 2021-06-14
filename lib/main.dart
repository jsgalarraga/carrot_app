import 'package:carrot_app/pages/root_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return MaterialApp(home: Center(child: Text('Ha ocurrido un problema al iniciar la aplicación')));
          }
          if (snapshot.connectionState == ConnectionState.done){
            return MaterialApp(
              title: 'Carrot Locations',
              theme: ThemeData(
                primarySwatch: Colors.deepOrange,
              ),
              home: MyHomePage(title: 'Carrot locations'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        }
    );
  }
}
