import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlacesPage extends StatelessWidget {
  const PlacesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('/markers').orderBy('name').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            try {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(snapshot.data?.docs[index]['name']),
                  subtitle: Text(
                    'Latitude: ${snapshot.data?.docs[index]['lat']} - Longitude: ${snapshot.data?.docs[index]['lng']}',
                  ),
                ),
              );
            } catch (e) {
              return Center(
                child: ListTile(
                  title: Text(
                    'Se ha producido un error. Comprueba tu conexión y vuelve a intentarlo',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
