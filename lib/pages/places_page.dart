import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                    '${AppLocalizations.of(context)!.lat}: ${snapshot.data?.docs[index]['lat']} -'
                        ' ${AppLocalizations.of(context)!.lng}: ${snapshot.data?.docs[index]['lng']}',
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
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.markerName),
              validator: (value){
                if (value!.isEmpty) return AppLocalizations.of(context)!.errorEmptyName;
              },
            ),
            TextFormField(
              controller: _latController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lat, hintText: '12.345'),
              keyboardType: TextInputType.number,
              validator: (value){
                if (value!.isEmpty) return AppLocalizations.of(context)!.errorEmptyLat;
                if (double.tryParse(value) == null)
                  return AppLocalizations.of(context)!.errorValidLat;
              },
            ),
            TextFormField(
              controller: _lngController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lng, hintText: '12.345'),
              keyboardType: TextInputType.number,
              validator: (value){
                if (value!.isEmpty) return AppLocalizations.of(context)!.errorEmptyLng;
                if (double.tryParse(value) == null)
                  return AppLocalizations.of(context)!.errorValidLng;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.save),
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
