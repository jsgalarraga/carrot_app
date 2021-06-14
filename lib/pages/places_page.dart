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
        onPressed: () {
          showDialog(context: context, builder: (BuildContext context) => AddPlaceDialog());
        },
      ),
    );
  }
}

class AddPlaceDialog extends StatefulWidget {
  const AddPlaceDialog({Key? key}) : super(key: key);

  @override
  _AddPlaceDialogState createState() => _AddPlaceDialogState();
}

class _AddPlaceDialogState extends State<AddPlaceDialog> {
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add new marker"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: 'Marker name'),
              validator: (value){
                if (value!.isEmpty) return 'Please, enter a marker name';
              },
            ),
            TextFormField(
              controller: _latController,
              decoration: InputDecoration(labelText: 'Latitude', hintText: '12.345'),
              keyboardType: TextInputType.number,
              validator: (value){
                if (value!.isEmpty) return 'Please, enter a latitude';
                if (double.tryParse(value) == null)
                  return 'Please, enter a valid latitude';
              },
            ),
            TextFormField(
              controller: _lngController,
              decoration: InputDecoration(labelText: 'Longitude', hintText: '12.345'),
              keyboardType: TextInputType.number,
              validator: (value){
                if (value!.isEmpty) return 'Please, enter a longitude';
                if (double.tryParse(value) == null)
                  return 'Please, enter a valid longitude';
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Save"),
          onPressed: () {
            if (_formKey.currentState!.validate()){
              _addMarker();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  void _addMarker(){
    CollectionReference markers = FirebaseFirestore.instance.collection('markers');
    markers.add({
      'name': _nameController.text,
      'lat': double.parse(_latController.text),
      'lng': double.parse(_lngController.text),
    }).catchError((error) {
      print("Failed to add marker: $error");
    });
  }
}
