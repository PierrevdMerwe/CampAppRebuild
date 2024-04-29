import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CampsiteDetailsPage extends StatelessWidget {
  final DocumentSnapshot campsite;

  CampsiteDetailsPage(this.campsite);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campsite Details'),
      ),
      body: Center(
        child: Text(
          'Campsite Name: ${campsite['name']}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}