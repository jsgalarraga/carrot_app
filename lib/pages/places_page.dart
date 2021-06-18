import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlacesPage extends StatelessWidget {
  /// Page that displays a list with created markers and allows to create new markers to show on MapsPage
  const PlacesPage({Key? key}) : super(key: key);

  void _addNewMarker(BuildContext context) {
    showDialog(context: context, builder: (BuildContext context) => AddPlaceDialog());
  }

  void _deleteMarker(String? markerId) {
    FirebaseFirestore.instance.collection('/markers').doc(markerId).delete();
  }

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
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () => _deleteMarker(snapshot.data?.docs[index].id),
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
        onPressed: () => _addNewMarker(context),
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

  String? _nameFieldValidator(String? value) {
    /// Validates the name of the marker
    if (value!.isEmpty) return AppLocalizations.of(context)!.errorEmptyName;
  }

  String? _latFieldValidator(String? value) {
    /// Validates the latitude of the marker's location
    // Checks if it's empty
    if (value!.isEmpty) return AppLocalizations.of(context)!.errorEmptyLat;
    //Checks if it's a number
    if (double.tryParse(value) == null) return AppLocalizations.of(context)!.errorValidLat;
    //Checks if its a valid latitude between -90 and 90 degrees
    if (!((double.parse(value) >= -90) && (double.parse(value) <= 90)))
      return AppLocalizations.of(context)!.errorValidLat;
  }

  String? _lngFieldValidator(String? value) {
    /// Validates the longitude of the marker's location
    // Checks if it's empty
    if (value!.isEmpty) return AppLocalizations.of(context)!.errorEmptyLng;
    //Checks if it's a number
    if (double.tryParse(value) == null) return AppLocalizations.of(context)!.errorValidLng;
    //Checks if its a valid latitude between -180 and 180 degrees
    if (!((double.parse(value) >= -180) && (double.parse(value) <= 180)))
      return AppLocalizations.of(context)!.errorValidLng;
  }

  void _cancelNewMarker() {
    /// Dismisses the new marker dialog
    Navigator.of(context).pop();
  }

  void _confirmNewMarker() {
    /// Creates the new marker and dismisses de dialog
    if (_formKey.currentState!.validate()) {
      _addMarker();
      Navigator.of(context).pop();
    }
  }

  void _addMarker() {
    /// Creates the marker in the database
    CollectionReference markers = FirebaseFirestore.instance.collection('markers');
    markers.add({
      'name': _nameController.text,
      'lat': double.parse(_latController.text),
      'lng': double.parse(_lngController.text),
    }).catchError((error) {
      print("Failed to add marker: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addMarker),
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
              validator: _nameFieldValidator,
            ),
            TextFormField(
              controller: _latController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lat, hintText: '12.345'),
              keyboardType: TextInputType.number,
              validator: _latFieldValidator,
            ),
            TextFormField(
              controller: _lngController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lng, hintText: '12.345'),
              keyboardType: TextInputType.number,
              validator: _lngFieldValidator,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () => _cancelNewMarker(),
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.save),
          onPressed: () => _confirmNewMarker(),
        ),
      ],
    );
  }
}
